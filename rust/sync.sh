#!/bin/sh
# Archive or install the Rust toolchain and Cargo tools declared beside this script.
set -eu

case "${1-}" in
    -h|--help)
        echo "Usage: sh rust/sync.sh --install | --archive"
        echo "  --install  Install the toolchain and Cargo tools from the adjacent manifests."
        echo "  --archive  Replace the manifests with the global default toolchain and installed Cargo tools."
        exit 0
        ;;
    --install|--archive) stage=$1 ;;
    '') echo 'Specify --install or --archive (see --help)' >&2; exit 1 ;;
    *) echo "Unexpected argument: $1" >&2; exit 1 ;;
esac
[ "$#" -eq 1 ] || { echo 'Too many arguments' >&2; exit 1; }

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir"

# Make rustup read the adjacent toolchain file rather than an environment override.
unset RUSTUP_TOOLCHAIN
export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"

if [ "$stage" = --archive ]; then
    archive_dir=$(mktemp -d)
    trap 'rm -rf "$archive_dir"' EXIT
    trap 'exit 1' HUP INT TERM

    # Query the global default explicitly: the adjacent manifest is a directory override.
    toolchain=$(rustup default)
    toolchain=${toolchain%% *}
    test -n "$toolchain"
    rustup run "$toolchain" rustc -vV > "$archive_dir/rustc"
    host=$(awk '$1 == "host:" {print $2}' "$archive_dir/rustc")
    test -n "$host"
    channel=${toolchain%-"$host"}
    case "$channel" in
        stable|beta|nightly|nightly-[0-9]*|beta-[0-9]*|[0-9]*.[0-9]*) ;;
        *) echo "Cannot archive a custom Rust toolchain: $toolchain" >&2; exit 1 ;;
    esac

    rustup component list --installed --toolchain "$toolchain" > "$archive_dir/components"
    rustup target list --installed --toolchain "$toolchain" > "$archive_dir/targets"
    cargo +"$toolchain" install --list > "$archive_dir/cargo"

    # Cargo's list includes indented executable names. Archive only package headers.
    # Reject Git/path sources instead of silently reinstalling them from crates.io.
    awk '
        /^[^[:space:]]/ {
            if (NF != 2 || $2 !~ /^v[0-9][^[:space:]]*:$/) {
                print "Cannot archive non-registry Cargo package: " $0 > "/dev/stderr"
                exit 1
            }
            version = substr($2, 2, length($2) - 2)
            print $1 "@" version
        }
    ' "$archive_dir/cargo" > "$archive_dir/packages"
    {
        echo '# One crates.io package per line; versions captured by sync.sh --archive.'
        sort "$archive_dir/packages"
    } > "$archive_dir/cargo-tools.txt"

    {
        printf '[toolchain]\nchannel = "%s"\nprofile = "minimal"\n' "$channel"
        awk -v host="$host" '
            BEGIN { print "components = ["; suffix = "-" host }
            {
                name = $1
                if (substr(name, length(name) - length(suffix) + 1) == suffix)
                    name = substr(name, 1, length(name) - length(suffix))
                if (name != "cargo" && name != "rustc" && name !~ /^rust-std($|-)/)
                    printf "  \"%s\",\n", name
            }
            END { print "]" }
        ' "$archive_dir/components"
        awk -v host="$host" '
            BEGIN { print "targets = [" }
            $1 != host { printf "  \"%s\",\n", $1 }
            END { print "]" }
        ' "$archive_dir/targets"
    } > "$archive_dir/rust-toolchain.toml"

    # Finish all queries before replacing either manifest.
    mv "$archive_dir/rust-toolchain.toml" rust-toolchain.toml
    mv "$archive_dir/cargo-tools.txt" cargo-tools.txt
    echo 'Rust toolchain and Cargo tools archived.'
    exit 0
fi

test -f rust-toolchain.toml
test -f cargo-tools.txt

if ! command -v rustup >/dev/null 2>&1; then
    installer=$(mktemp)
    trap 'rm -f "$installer"' EXIT
    trap 'exit 1' HUP INT TERM
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$installer"
    sh "$installer" -y --no-modify-path --default-toolchain none
    rm -f "$installer"
    trap - EXIT HUP INT TERM
fi

# With no toolchain argument, rustup uses rust-toolchain.toml in this directory.
rustup toolchain install --no-self-update
toolchain=$(rustup show active-toolchain | awk '{print $1}')
test -n "$toolchain"
rustup default "$toolchain"

while IFS= read -r package || [ -n "$package" ]; do
    package=$(printf '%s\n' "$package" | sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//')
    [ -n "$package" ] || continue
    case "$package" in
        -*|*[[:space:]]*)
            echo "Invalid Cargo package entry: $package" >&2
            exit 1
            ;;
    esac
    cargo install --locked "$package"
done < cargo-tools.txt

echo 'Rust toolchain and Cargo tools are ready.'
