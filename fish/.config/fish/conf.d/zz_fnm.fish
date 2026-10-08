# Configure pnpm and global command paths before selecting Node with fnm.
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

fish_add_path --global --prepend "$HOME/.npm-global/bin"

set -l fnm_path
set -l os_name (uname -s)

if set -q FNM_PATH; and test -x "$FNM_PATH/fnm"
    set fnm_path "$FNM_PATH"
else
    set -l fnm_command (command -s fnm)

    if set -q fnm_command[1]
        set fnm_path (path dirname "$fnm_command")
    else
        set -l fnm_candidates

        if set -q HOMEBREW_PREFIX
            set -a fnm_candidates "$HOMEBREW_PREFIX/opt/fnm/bin"
        end

        if test "$os_name" = Darwin
            set -a fnm_candidates \
                /opt/homebrew/opt/fnm/bin \
                /usr/local/opt/fnm/bin
        end

        set -a fnm_candidates "$HOME/.fnm"

        if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
            set -a fnm_candidates "$XDG_DATA_HOME/fnm"
        else if test "$os_name" = Darwin
            set -a fnm_candidates "$HOME/Library/Application Support/fnm"
        else
            set -a fnm_candidates "$HOME/.local/share/fnm"
        end

        for candidate in $fnm_candidates
            if test -x "$candidate/fnm"
                set fnm_path "$candidate"
                break
            end
        end
    end
end

if set -q fnm_path[1]
    set -gx FNM_PATH "$fnm_path"

    if not contains -- "$FNM_PATH" $PATH
        set -gx PATH "$FNM_PATH" $PATH
    end
end

# Initialize fnm after the other conf.d files have configured PATH.
if status is-interactive; and set -q FNM_PATH
    command "$FNM_PATH/fnm" env --shell fish | source
    if test $pipestatus[1] -eq 0
        command "$FNM_PATH/fnm" use default
    end
end
