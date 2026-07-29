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

    command "$FNM_PATH/fnm" env --shell fish | source
end
