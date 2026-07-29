source (dirname (realpath (status --current-filename)))/easy_eel/prompt_sections/user.fish
source (dirname (realpath (status --current-filename)))/easy_eel/prompt_sections/host.fish
source (dirname (realpath (status --current-filename)))/easy_eel/prompt_sections/directory.fish
source (dirname (realpath (status --current-filename)))/easy_eel/prompt_sections/git.fish
source (dirname (realpath (status --current-filename)))/easy_eel/prompt_sections/prompt_indicator.fish

function fish_prompt
    set -l previous_command_status $status
    set -l any_section_displayed 0
    
    if not set -q EASY_EEL_HIDE_USER; or test "$EASY_EEL_HIDE_USER" != "true"
        _easy_eel_display_prompt_section_user
        echo -n " "
        set any_section_displayed 1
    end

    if not set -q EASY_EEL_HIDE_HOST; or test "$EASY_EEL_HIDE_HOST" != "true"
        _easy_eel_display_prompt_section_host
        echo -n " "
        set any_section_displayed 1
    end

    if not set -q EASY_EEL_HIDE_CURRENT_DIRECTORY; or test "$EASY_EEL_HIDE_CURRENT_DIRECTORY" != "true"
        _easy_eel_display_prompt_section_current_directory
        echo -n " "
        set any_section_displayed 1
    end

    if not set -q EASY_EEL_HIDE_GIT_STATE; or test "$EASY_EEL_HIDE_GIT_STATE" != "true"
        _easy_eel_display_prompt_section_git_state
        echo -n " "
        set any_section_displayed 1
    end

    if test $any_section_displayed -eq 1
        echo
    end

    _easy_eel_display_prompt_indicator $previous_command_status
end
