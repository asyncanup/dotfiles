# Setup fzf
# ---------
if [[ ! "$PATH" == */home/abishnoi/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/home/abishnoi/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/abishnoi/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/abishnoi/.fzf/shell/key-bindings.bash"
