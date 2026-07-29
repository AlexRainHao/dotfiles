set -q RBENV_ROOT; or set -gx RBENV_ROOT "$HOME/.rbenv"
set -gx RUBY_BUILD_MIRROR_URL "https://cache.ruby-china.com"

if test -d "$RBENV_ROOT/bin"
    fish_add_path --global --prepend "$RBENV_ROOT/bin"
end

if command -q rbenv
    rbenv init - fish | source
end
