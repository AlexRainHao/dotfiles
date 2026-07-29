switch (uname)
    case Darwin
        set -gx PNPM_HOME "$HOME/Library/pnpm"
    case Linux
        if set -q XDG_DATA_HOME
            set -gx PNPM_HOME "$XDG_DATA_HOME/pnpm"
        else
            set -gx PNPM_HOME "$HOME/.local/share/pnpm"
        end
end

if set -q PNPM_HOME
    fish_add_path --global --prepend "$PNPM_HOME/bin" "$PNPM_HOME"
end
