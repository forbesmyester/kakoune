# http://tmux.github.io/
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
# Tmux version >= 2 is required to use this module

hook global ModuleLoaded tmux %{
    require-module tmux-repl
}

provide-module tmux-repl %{

declare-option -docstring "tmux pane id in which the REPL is running" str tmux_repl_id

define-command -hidden -params 1.. tmux-repl-impl %{
    evaluate-commands %sh{
        if [ -z "$TMUX" ]; then
            echo 'fail This command is only available in a tmux session'
            exit
        fi
        tmux_args="$1"
        shift
        tmux $tmux_args "$@"
        printf "set-option current tmux_repl_id '%s'" $(tmux display-message -p '#{session_id}:#{window_id}.#{pane_id}')
    }
}

define-command tmux-repl-vertical -params 0.. -command-completion -docstring "Create a new vertical pane for repl interaction" %{
    tmux-repl-impl 'split-window -v' %arg{@}
}

define-command tmux-repl-horizontal -params 0.. -command-completion -docstring "Create a new horizontal pane for repl interaction" %{
    tmux-repl-impl 'split-window -h' %arg{@}
}

define-command tmux-repl-window -params 0.. -command-completion -docstring "Create a new window for repl interaction" %{
    tmux-repl-impl 'new-window' %arg{@}
}

define-command -hidden tmux-send-text -params 0..2 -docstring %{
        tmux-send-text [text] [newline]: Send text to the REPL pane.

        If text is not passed or an empty string, the selection is used.
        If newline is 1 a new line is appended to what is sent to the repl
    } %{
    nop %sh{
        if [ $# -eq 0 ] || [ "$1" = "" ]; then
            tmux set-buffer -b kak_selection -- "${kak_selection}"
        else
            tmux set-buffer -b kak_selection -- "$1"
        fi
        tmux paste-buffer -b kak_selection -t "$kak_opt_tmux_repl_id"
        if [ "$#" -gt 1 ] && [ "$2" = "1" ]; then
            tmux send-keys -t "$kak_opt_tmux_repl_id" "ENTER"
        fi
    }
}

alias global repl-new tmux-repl-horizontal
alias global repl-send-text tmux-send-text

}
