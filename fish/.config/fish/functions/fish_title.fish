function fish_title
    if functions -q easy_eel_override_title
        easy_eel_override_title
    else
        prompt_pwd
    end
end
