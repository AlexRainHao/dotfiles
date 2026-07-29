complete --command preinstall --no-files

complete --command preinstall \
    --condition __fish_use_subcommand \
    --arguments tpm \
    --description "Install the tmux plugin manager"

complete --command preinstall \
    --condition __fish_use_subcommand \
    --arguments jetbra \
    --description "Install Jetbra for desktop applications"

complete --command preinstall \
    --condition __fish_use_subcommand \
    --arguments uv \
    --description "Install uv and generate Fish completions"

complete --command preinstall \
    --condition __fish_use_subcommand \
    --arguments rust \
    --description "Install Rust and rust-analyzer with rustup"

complete --command preinstall \
    --condition __fish_use_subcommand \
    --arguments fvm \
    --description "Install Flutter Version Management"

complete --command preinstall \
    --condition __fish_use_subcommand \
    --arguments fnm \
    --description "Install Fast Node Manager"
