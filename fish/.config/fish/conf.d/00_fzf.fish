set -gx FZF_DEFAULT_COMMAND "fd --hidden --follow --exclude .git --exclude node_modules"
set -gx FZF_DEFAULT_OPTS '--no-mouse --height 70% -1 --reverse --multi --inline-info --preview=\'[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300\''
