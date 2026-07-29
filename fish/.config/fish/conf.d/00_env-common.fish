set -gx DISPLAY :0
set -gx EDITOR nvim
set -gx OBJC_DISABLE_INITIALIZE_FORK_SAFETY YES

########################################
# user binaries
########################################
if test -d "$HOME/.local/bin"
    fish_add_path --global --prepend "$HOME/.local/bin"
end

########################################
# tensorflow
########################################
set -gx TFHUB_CACHE_DIR $HOME/.cache/tfhub_cache

########################################
# ollama
########################################
set -gx OLLAMA_HOST "0.0.0.0:11434"
