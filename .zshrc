# starship prompt
eval "$(starship init zsh)"

# fzf install
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# personal utilities
export PATH="$HOME/bin:$HOME/bin/node_modules/.bin:$HOME/.local/bin:$PATH"

# macOS-specific paths
if [[ "$(uname)" == "Darwin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
fi

# Deno-installed utilities
export PATH="$HOME/.deno/bin:$PATH"

export EDITOR="nvim"

# Command history format
export HISTTIMEFORMAT="%Y-%m-%d %T "

# Copy last command's output to clipboard
if [[ "$(uname)" == "Darwin" ]]; then
  alias cplast='fc -e - | pbcopy'
else
  alias cplast='fc -e - | wl-copy -n'
fi

# bin for go installed packages
export PATH="$PATH:$HOME/go/bin"

eval "$(direnv hook zsh)"

# Local machine-specific overrides (OS-specific paths, distro-specific config, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
