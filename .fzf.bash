# Setup fzf
# ---------
if [[ ! "$PATH" == */home/dev/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/dev/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/dev/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/dev/.fzf/shell/key-bindings.bash"
