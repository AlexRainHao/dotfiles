if test -x "$HOME/go/bin"
    fish_add_path --global --prepend "$HOME/go/bin"
end

set -gx GOPROXY "https://goproxy.cn,direct"
