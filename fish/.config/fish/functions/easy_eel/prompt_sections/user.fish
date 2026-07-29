source (dirname (realpath (status --current-filename)))/../colors.fish

function _easy_eel_display_prompt_section_user
    set -q EASY_EEL_COLOR_USER; or set -l EASY_EEL_COLOR_USER brred
    _easy_eel_colored_print $EASY_EEL_COLOR_USER (_easy_eel_user)
end

function _easy_eel_user
    if functions -q easy_eel_override_user
        easy_eel_override_user
        return
    end

    if set -q USER
        echo $USER
    else
        whoami
    end
end
