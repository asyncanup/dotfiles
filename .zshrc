# starship prompt
eval "$(starship init zsh)"

# fzf install
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# personal utilities
export PATH="$HOME/bin:$HOME/bin/node_modules/.bin:$HOME/.local/bin:$PATH"

# homebrew-installed utilities
export PATH="/opt/homebrew/bin:$PATH"

# PostgreSQL/psql
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Deno-installed utilities
export PATH="/home/bish/.deno/bin:$PATH"

export EDITOR="nvim"

# Command history format
export HISTTIMEFORMAT="%Y-%m-%d %T "

# Copy last command's output to clipboard
alias cplast='fc -e - | wl-copy -n'

# bin for go installed packages
export PATH="$PATH:$HOME/go/bin"

# Local machine-specific overrides (OS-specific paths, distro-specific config, etc.)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
