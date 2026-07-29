function preinstall --description 'Initialize machine prerequisites'
    if test (count $argv) -ne 1
        echo 'Usage: preinstall <command>' >&2
        echo 'Commands: tpm, jetbra, uv, rust, fvm' >&2
        return 2
    end

    switch "$argv[1]"
        case tpm
            __preinstall_tpm
            return $status

        case jetbra
            __preinstall_jetbra
            return $status

        case uv
            __preinstall_uv
            return $status

        case rust
            __preinstall_rust
            return $status

        case fvm
            __preinstall_fvm
            return $status

        case '*'
            echo "preinstall: unsupported command: $argv[1]" >&2
            return 2
    end
end

function __preinstall_tpm --description 'Install the tmux plugin manager'
    set -l plugins_dir "$HOME/.tmux/plugins"
    set -l target "$plugins_dir/tpm"

    if test -e "$target/.git"
        echo "preinstall: TPM already exists at $target; skipping"
        return 0
    end

    if test -e "$target"
        echo "preinstall: target exists but is not a Git repository: $target" >&2
        return 1
    end

    command mkdir -p "$plugins_dir"
    or return 1

    command git clone https://github.com/tmux-plugins/tpm "$target"
    return $status
end

function __preinstall_jetbra --description 'Install Jetbra for Fish and desktop applications'
    set -l installer "$HOME/.config/jetbra/scripts/install.sh"

    if not test -f "$installer"
        printf 'install_jetbra: installer not found: %s\n' "$installer" >&2
        return 1
    end

    command sh "$installer"
    set -l install_status $status

    if test "$install_status" -ne 0
        return "$install_status"
    end

    set -l fish_env "$HOME/.config/fish/conf.d/20_jetbrains.fish"
    if test -f "$fish_env"
        source "$fish_env"
    end

    if test (uname -s) = Darwin
        echo 'Jetbra installed. Log out and back in before launching JetBrains apps from the Dock.'
    end
end

function __preinstall_uv --description 'Install uv and generate Fish completions'
    if command -q uv
        echo 'preinstall: uv already exists; skipping installation'
    else
        command curl -LsSf https://astral.sh/uv/install.sh | command sh
        set -l install_status $pipestatus

        if test $install_status[1] -ne 0
            return $install_status[1]
        end

        if test $install_status[2] -ne 0
            return $install_status[2]
        end
    end

    set -l uv_bin (command -s uv)
    set -l uvx_bin (command -s uvx)

    if not set -q uv_bin[1]; and test -x "$HOME/.local/bin/uv"
        set uv_bin "$HOME/.local/bin/uv"
    end

    if not set -q uvx_bin[1]; and test -x "$HOME/.local/bin/uvx"
        set uvx_bin "$HOME/.local/bin/uvx"
    end

    set -l completion_dir "$HOME/.config/fish/completions"
    command mkdir -p "$completion_dir"
    or return 1

    command "$uv_bin" generate-shell-completion fish >"$completion_dir/uv.fish"
    or return $status

    command "$uvx_bin" --generate-shell-completion fish >"$completion_dir/uvx.fish"
    or return $status

    echo "preinstall: generated uv and uvx Fish completions in $completion_dir"
end

function __preinstall_rust --description 'Install Rust and rust-analyzer with rustup'
    set -l rustup_bin (command -s rustup)

    if not set -q rustup_bin[1]; and test -x "$HOME/.cargo/bin/rustup"
        set rustup_bin "$HOME/.cargo/bin/rustup"
    end

    if set -q rustup_bin[1]
        echo 'preinstall: rustup already exists; skipping installation'
    else
        command curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
            command sh -s -- -y --no-modify-path
        set -l install_status $pipestatus

        if test $install_status[1] -ne 0
            return $install_status[1]
        end

        if test $install_status[2] -ne 0
            return $install_status[2]
        end

        set rustup_bin "$HOME/.cargo/bin/rustup"
    end

    command "$rustup_bin" show active-toolchain >/dev/null 2>&1
    set -l toolchain_status $status

    if test $toolchain_status -ne 0
        command "$rustup_bin" default stable
        or return $status
    end

    set -l installed_components (command "$rustup_bin" component list --installed)
    set -l component_list_status $status

    if test $component_list_status -ne 0
        return $component_list_status
    end

    set -l missing_components

    if not string match --quiet --regex '^rust-analyzer($|-)' -- $installed_components
        set -a missing_components rust-analyzer
    end

    if not string match --quiet --regex '^rust-src($|-)' -- $installed_components
        set -a missing_components rust-src
    end

    if not string match --quiet --regex '^clippy($|-)' -- $installed_components
        set -a missing_components clippy
    end

    if set -q missing_components[1]
        command "$rustup_bin" component add $missing_components
        or return $status
    end

    set -l rust_bin_dir (path dirname "$rustup_bin")

    echo 'preinstall: Rust toolchains'
end

function __preinstall_fvm --description 'Install Flutter Version Management'
    set -l fvm_bin (command -s fvm)

    if not set -q fvm_bin[1]; and test -x "$HOME/fvm/bin/fvm"
        set fvm_bin "$HOME/fvm/bin/fvm"
    end

    if set -q fvm_bin[1]
        echo "preinstall: FVM already exists at $fvm_bin; skipping"
        return 0
    end

    command curl -fsSL https://fvm.app/install.sh | command bash
    set -l install_status $pipestatus

    if test $install_status[1] -ne 0
        return $install_status[1]
    end

    if test $install_status[2] -ne 0
        return $install_status[2]
    end

    set fvm_bin "$HOME/fvm/bin/fvm"

    if not test -x "$fvm_bin"
        echo 'preinstall: FVM executable was not found after installation' >&2
        return 1
    end

    echo "preinstall: FVM is ready at $fvm_bin"
end
