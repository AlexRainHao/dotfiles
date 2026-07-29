source (dirname (realpath (status --current-filename)))/../colors.fish

function _easy_eel_display_prompt_section_current_directory
    set -q EASY_EEL_COLOR_CURRENT_DIRECTORY; or set -l EASY_EEL_COLOR_CURRENT_DIRECTORY green

    echo -n "in "
    _easy_eel_colored_print $EASY_EEL_COLOR_CURRENT_DIRECTORY (_easy_eel_current_directory)
end

function _easy_eel_current_directory
    if functions -q easy_eel_override_current_directory
        easy_eel_override_current_directory
        return
    end

    prompt_pwd
end
