# Use powerline
USE_POWERLINE="true"
# Has weird character width
# Example:
#    is not a diamond
HAS_WIDECHARS="false"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  source /usr/share/zsh/manjaro-zsh-prompt
fi

# fzf install, added by vim Plug probably
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# nodejs manual install from binary package
export PATH="$PATH:/home/bish/ext/node/node-v20.11.0-linux-x64/bin"

# personal utilities
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Deno
export PATH="/opt/homebrew/bin:$PATH"
# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
