if [ "$(uname)" == "Darwin" ]; then
  FZF_DIR="/usr/local/opt/fzf"
else
  FZF_DIR="$HOME/.fzf"
fi

# Setup fzf
# ---------
if [[ ! "$PATH" == */.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$FZF_DIR/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$FZF_DIR/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
[[ -f $FZF_DIR/shell/key-bindings.bash ]] && \
  source "$FZF_DIR/shell/key-bindings.bash"
