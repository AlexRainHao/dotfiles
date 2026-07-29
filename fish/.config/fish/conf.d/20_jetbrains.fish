set -l jetbra_vmoptions_dir "$HOME/.config/jetbra/vmoptions"

if test -d "$jetbra_vmoptions_dir"
    for product in \
            idea \
            clion \
            phpstorm \
            goland \
            pycharm \
            webstorm \
            webide \
            rider \
            datagrip \
            rubymine \
            dataspell \
            aqua \
            rustrover \
            gateway \
            jetbrains_client \
            jetbrainsclient \
            studio \
            devecostudio
        set -l vmoptions_file "$jetbra_vmoptions_dir/$product.vmoptions"

        if test -f "$vmoptions_file"
            set -l env_name (string upper -- "$product")_VM_OPTIONS
            set -gx "$env_name" "$vmoptions_file"
        end
    end
end
