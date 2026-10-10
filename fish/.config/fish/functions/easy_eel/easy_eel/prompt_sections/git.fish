function _easy_eel_display_prompt_section_git_state
    # Gather git info
    set -l info (git status --porcelain=v2 --branch 2>/dev/null)
    or return

    set -l branch ""
    set -l dirty 0
    set -l untracked 0
    set -l ahead 0
    set -l behind 0
    set -l stashed 0

    for line in $info
        switch $line
            case '# branch.head *'
                set branch (string sub -s 15 $line)
            case '# branch.ab *'
                string match -rq '\+[1-9]' $line; and set ahead 1
                string match -rq ' -[1-9]' $line; and set behind 1
            case '1 *' '2 *'
                set dirty 1
            case '? *'
                set untracked 1
        end
    end

    test "$branch" = "(detached)"; and set branch (git rev-parse --short HEAD 2>/dev/null)
    git rev-parse --verify --quiet refs/stash &>/dev/null; and set stashed 1

    # Symbols
    set -q EASY_EEL_SYMBOL_GIT_DIRTY; or set -l EASY_EEL_SYMBOL_GIT_DIRTY '!'
    set -q EASY_EEL_SYMBOL_GIT_CLEAN; or set -l EASY_EEL_SYMBOL_GIT_CLEAN '✓'
    set -q EASY_EEL_SYMBOL_GIT_UNTRACKED; or set -l EASY_EEL_SYMBOL_GIT_UNTRACKED '☡'
    set -q EASY_EEL_SYMBOL_GIT_STASH; or set -l EASY_EEL_SYMBOL_GIT_STASH '↩'
    set -q EASY_EEL_SYMBOL_GIT_AHEAD; or set -l EASY_EEL_SYMBOL_GIT_AHEAD '+'
    set -q EASY_EEL_SYMBOL_GIT_BEHIND; or set -l EASY_EEL_SYMBOL_GIT_BEHIND '-'

    # Colors
    set -q EASY_EEL_COLOR_GIT_BRANCH; or set -l EASY_EEL_COLOR_GIT_BRANCH purple
    set -q EASY_EEL_COLOR_GIT_STATE; or set -l EASY_EEL_COLOR_GIT_STATE blue

    # Build state
    set -l state (test $dirty -eq 1; and echo $EASY_EEL_SYMBOL_GIT_DIRTY; or echo $EASY_EEL_SYMBOL_GIT_CLEAN)
    test $untracked -eq 1; and set state "$state$EASY_EEL_SYMBOL_GIT_UNTRACKED"
    test $ahead -eq 1; and set state "$state$EASY_EEL_SYMBOL_GIT_AHEAD"
    test $behind -eq 1; and set state "$state$EASY_EEL_SYMBOL_GIT_BEHIND"
    test $stashed -eq 1; and set state "$state$EASY_EEL_SYMBOL_GIT_STASH"

    # Display
    echo -n "on "
    set_color $EASY_EEL_COLOR_GIT_BRANCH; echo -n $branch; set_color normal
    echo -n " "
    set_color $EASY_EEL_COLOR_GIT_STATE; echo -n "[$state]"; set_color normal
end
