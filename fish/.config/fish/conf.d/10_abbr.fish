abbr -a --global ls 'exa -lh --icons'
abbr -a --global ll 'exa -lh --icons'
abbr -a --global la 'exa -lah --icons'
abbr -a --global tailf 'tail -f'
abbr -a --global go2code 'cd $CODE_HOME'
abbr -a --global lg lazygit
abbr -a --global lq lazysql
abbr -a --global lzd lazydocker
abbr -a --global x tmux
abbr -a --global rr yazi

switch (uname)
    case Darwin
        abbr -a --global useGpu "sudo pmset -a GPUSwitch 1"
        abbr -a --global banGpu "sudo pmset -a GPUSwitch 0"
end
