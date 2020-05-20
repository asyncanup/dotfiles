# Setup fzf
# ---------
if [[ ! "$PATH" == */.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
[[ -f $HOME/.fzf/shell/key-bindings.bash ]] && \
  source "$HOME/.fzf/shell/key-bindings.bash"
