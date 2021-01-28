hook global ModuleLoaded kitty %{
    require-module kitty-repl
}

provide-module kitty-repl %{

define-command -params .. -shell-completion \
    -docstring %{
        kitty-repl [<arguments>]: Create a new window for repl interaction.

        All optional parameters are forwarded to the new window.
    } \
    kitty-repl %{
    nop %sh{
        if [ $# -eq 0 ]; then
            cmd="${SHELL:-/bin/sh}"
        else
            cmd="$*"
        fi
        kitty @ new-window --no-response --window-type $kak_opt_kitty_window_type --title kak_repl_window --cwd "$PWD" $cmd < /dev/null > /dev/null 2>&1 &
    }
}

define-command -hidden -params 0..2 \
    -docstring %{
        kitty-send-text [text] [newline]: Send text to the REPL window.

        If text is not passed or an empty string, the selection is used.
        If newline is 1 a new line is appended to what is sent to the repl
    } \
    kitty-send-text %{
    nop %sh{
        if [ $# -eq 0 ] || [ "$1" = "" ]; then
            text="$kak_selection"
        else
            text="$1"
        fi
        if [ "$#" -gt 1 ] && [ "$2" = "1" ]; then
            kitty @ send-text -m=title:kak_repl_window "$text\n"
        else
            kitty @ send-text -m=title:kak_repl_window "$text"
        fi
    }
}

alias global repl-new kitty-repl
alias global repl-send-text kitty-send-text

}
