# Load after kidonng/zoxide.fish. The plugin owns z/zi and its PWD hook;
# this file only redirects the database and schedules background snapshots.
if status is-interactive; and command -q zoxide
    set -l helper (path resolve (status dirname)/../functions/__zoxide_runtime.py)

    if test "$ZOXIDE_RUNTIME_ENABLED" != true
        # Also handle a nested/reloaded shell inheriting an enabled session.
        # Finish its last snapshot before restoring the persistent database path.
        if set -q __dotfiles_zoxide_runtime_dir __dotfiles_zoxide_persistent_dir _ZO_DATA_DIR
            and test "$_ZO_DATA_DIR" = "$__dotfiles_zoxide_runtime_dir"
            if not command python3 "$helper" persist "$__dotfiles_zoxide_persistent_dir" "$__dotfiles_zoxide_runtime_dir"
                echo 'zoxide: could not save runtime history; keeping its database path' >&2
                return 1
            end
            set -gx _ZO_DATA_DIR "$__dotfiles_zoxide_persistent_dir"
        end
        functions -e __dotfiles_zoxide_schedule_persist
        set -e __dotfiles_zoxide_runtime_dir
        set -e __dotfiles_zoxide_persistent_dir
        set -e __dotfiles_zoxide_persist_helper
        return 0
    end

    # Unix capability checks, independent of the operating system name.
    set -l runtime_root "$ZOXIDE_RUNTIME_DIR"
    if test -z "$runtime_root"
        set runtime_root "$XDG_RUNTIME_DIR"
    end
    if test -z "$runtime_root"; or not test -d "$runtime_root"; or not test -w "$runtime_root"; or not command -q python3
        return 0
    end

    functions -e __dotfiles_zoxide_schedule_persist

    set -l persistent_dir
    if set -q __dotfiles_zoxide_runtime_dir __dotfiles_zoxide_persistent_dir
        and set -q _ZO_DATA_DIR
        and test "$_ZO_DATA_DIR" = "$__dotfiles_zoxide_runtime_dir"
        set persistent_dir "$__dotfiles_zoxide_persistent_dir"
    else if set -q _ZO_DATA_DIR; and test -n "$_ZO_DATA_DIR"
        set persistent_dir "$_ZO_DATA_DIR"
    else if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
        set persistent_dir "$XDG_DATA_HOME/zoxide"
    else
        set persistent_dir "$HOME/.local/share/zoxide"
    end

    set -l locations (command python3 "$helper" init "$persistent_dir" "$runtime_root")
    if test $status -eq 0; and test (count $locations) -eq 2
        # Nested Fish sessions must retain the original persistent path.
        set -gx __dotfiles_zoxide_persistent_dir "$locations[1]"
        set -gx __dotfiles_zoxide_runtime_dir "$locations[2]"
        set -gx _ZO_DATA_DIR "$locations[2]"
        set -g __dotfiles_zoxide_persist_helper "$helper"
    end

    if set -q __dotfiles_zoxide_runtime_dir _ZO_DATA_DIR
        and test "$_ZO_DATA_DIR" = "$__dotfiles_zoxide_runtime_dir"
        and set -q __dotfiles_zoxide_persist_helper
        # Runs after the plugin's directory update; no duplicate zoxide add.
        function __dotfiles_zoxide_schedule_persist --on-variable PWD --on-event fish_exit
            test -z "$fish_private_mode"; or return
            command python3 "$__dotfiles_zoxide_persist_helper" persist \
                "$__dotfiles_zoxide_persistent_dir" "$__dotfiles_zoxide_runtime_dir" </dev/null >/dev/null 2>>"$__dotfiles_zoxide_runtime_dir/persist.log" &
            disown $last_pid
        end
    end
end
