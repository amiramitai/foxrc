function code() {
    # locate the vscode remote server and open it from the client window 
    CODE=$(find ~/.vscode-server/bin/ -name "code" -printf "%T@ %Tc %p\n" | sort -n | tail -n 1 | awk '{print $NF}')
    VSCODE_IPC_HOOK_CLI=$(netstat -an | grep -Eo "/.*/vscode-ipc.*\.sock" | head -n 1)
    VSCODE_IPC_HOOK_CLI=$VSCODE_IPC_HOOK_CLI $CODE -g $@
}

function live_grep() {
    # live grep using fzf.
    # To launch: ctrl+g
    # press enter to select current filepath
    # press ctrl+g re-grep result with fzf
    # press ctrl+s to open with vscode
    # press ctrl+v to open with vim
    local tmpfile=$(mktemp /tmp/livegrep.data.XXXXXX)
    local editorfile=$(mktemp /tmp/livegrep.editor.XXXXXX)
    # break on error
    set -e
    # allow ctrl-c shortcut for vscode
    trap "" INT
    local selected=$(printf '' | fzf --ansi --header='Type to Live-grep' --phony --no-height \
                                     --header "Ctrl-G: fzf results, Ctrl-V: open with vim, Ctrl-C: open with code, Enter: drop to selection to commandline" \
                                     --bind "change:execute-silent(rg -i --color=always --vimgrep {q} > ${tmpfile})+reload(cat ${tmpfile})" \
                                     --bind "ctrl-v:execute-silent(printf 'vim' > $editorfile)+accept" \
                                     --bind "ctrl-g:execute-silent(printf 'fzf' > $editorfile)+accept" \
                                     --bind "ctrl-c:execute-silent(printf 'code' > $editorfile)+accept")
    local editor=$(cat $editorfile)
    case "$editor" in
        "fzf")
            rm -rf $editorfile
            selected=$(cat $tmpfile | fzf --ansi \
                                          --header "Ctrl-V: open with vim, Ctrl-C: open with code, Enter: drop to selection to commandline" \
                                          --bind "ctrl-v:execute-silent(printf 'vim' > $editorfile)+accept" \
                                          --bind "ctrl-c:execute-silent(printf 'code' > $editorfile)+accept");
        ;;
        *)
    esac
    editor=$(cat $editorfile)
    printf $selected > /tmp/s
    rm -rf $tmpfile
    rm -rf $editorfile
    filepath=$(realpath $(printf $selected | cut -d ":" -f1))
    line=$(echo $selected | cut -d ":" -f2)
    char=$(echo $selected | cut -d ":" -f3)
    case "$editor" in
        "vim")
            zsh -c "vim $filepath +$line < $TTY"
        ;;
        "code")
            code $filepath:$line:$char
        ;;
        *)
            LBUFFER=$LBUFFER$filepath:$line:$char
    esac
    zle reset-prompt
    zle redisplay
}

function kill_proccess() {
    # using fzf to select a process to kill
    kill -9 $(ps aux | fzf --preview-window "down:60%:wrap" | awk '{print $2}')
}

function up() {
    # travels one directory up
    cd ..
    BUFFER=""
    zle accept-line
}

# ctrl+g would live grep
zle     -N   live_grep
bindkey '^G' live_grep

# ctrl+k would bring up the kill process selection
zle     -N   kill_proccess
bindkey '^K' kill_proccess

# alt+up would go up a directory
zle     -N   up
bindkey '[A' up
