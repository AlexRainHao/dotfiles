function install_jetbra --description 'Install Jetbra for Fish and desktop applications'
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
