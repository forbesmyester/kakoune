hook global ModuleLoaded x11 %{
    require-module x11-repl
}

provide-module x11-repl %{

declare-option -docstring "window id of the REPL window" str x11_repl_id

define-command -docstring %{
    x11-repl [<arguments>]: create a new window for repl interaction
    All optional parameters are forwarded to the new window
} \
    -params .. \
    -shell-completion \
    x11-repl %{ x11-terminal sh -c %{
        winid="${WINDOWID:-$(xdotool search --pid ${PPID} | tail -1)}"
        printf "evaluate-commands -try-client $1 \
            'set-option current x11_repl_id ${winid}'" | kak -p "$2"
        shift 2;
        [ "$1" ] && "$@" || "$SHELL"
    } -- %val{client} %val{session} %arg{@}
}

define-command x11-send-text -params 0..2 -docstring %{
        x11-send-text [text] [newline]: Send text to the REPL window.

        If text is not passed or an empty string, the selection is used.
        If newline is 0 then no new line is appended to what is sent to the repl
        } %{
    evaluate-commands %sh{
        FORMAT="%s\\n"
        [ "$#" -gt 1 ] && [ "$2" = "0" ] && FORMAT="%s"
        (([ "$#" -gt 0 ] && [ "$1" != "" ]) && printf "$FORMAT" "$1" || printf "$FORMAT" "${kak_selection}" ) | xsel -i ||
        echo 'fail x11-send-text: failed to run xsel, see *debug* buffer for details' &&
        kak_winid=$(xdotool getactivewindow) &&
        xdotool windowactivate "${kak_opt_x11_repl_id}" key --clearmodifiers Shift+Insert &&
        xdotool windowactivate "${kak_winid}" ||
        echo 'fail x11-send-text: failed to run xdotool, see *debug* buffer for details'
    }
}

alias global repl-new x11-repl
alias global repl-send-text x11-send-text

}
