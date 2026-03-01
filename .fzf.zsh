FZF_DIR="$HOME/.fzf"

# Setup fzf
# ---------
if [[ ! "$PATH" == */.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}$FZF_DIR/bin"
fi

source <(fzf --zsh)
