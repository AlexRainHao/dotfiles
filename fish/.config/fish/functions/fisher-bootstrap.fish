function fisher-bootstrap --description 'Initialize Fisher state and update plugins'
    if test (count $argv) -ne 0
        echo 'Usage: fisher-bootstrap' >&2
        return 2
    end

    set -l plugins_file "$__fish_config_dir/fish_plugins"

    if not test -s "$plugins_file"
        echo "fisher-bootstrap: plugin manifest not found or empty: $plugins_file" >&2
        return 1
    end

    if not functions -q fisher
        echo 'fisher-bootstrap: fisher is not available' >&2
        return 1
    end

    if not set -q _fisher_plugins[1]
        set -l plugins (string match --regex '^[^\s]+$' <"$plugins_file")

        if not set -q plugins[1]
            echo "fisher-bootstrap: no plugins found in $plugins_file" >&2
            return 1
        end

        # The plugin files are managed with this dotfiles repository, but
        # Fisher's per-machine universal state is intentionally not tracked.
        # Seed the manifest so Fisher updates the existing files instead of
        # treating them as conflicting, newly installed files.
        set --universal _fisher_plugins $plugins
        or return $status

        echo 'fisher-bootstrap: initialized Fisher state from fish_plugins'
    end

    fisher update
end
