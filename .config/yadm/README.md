# YADM Dotfiles Configuration

This repository uses **machine-specific `.local` override files** to handle OS-specific and machine-specific configurations.

## How It Works

Main dotfiles (`.bashrc`, `.zshrc`, `.vimrc`, etc.) contain **cross-platform defaults**.
Each file sources a corresponding `.local` file if it exists for machine-specific overrides.

## Local Override Files (NOT tracked by yadm)

These files are `.gitignore`d and should be created manually on each machine:

- `~/.zshrc.local` - OS/machine-specific zsh config
- `~/.bashrc.local` - OS/machine-specific bash config
- `~/.fzf.bash.local` - OS/machine-specific fzf config
- `~/.vimrc.local` - Machine-specific vim/nvim config
- `~/.config/yadm/bootstrap.local` - OS-specific bootstrap script

## Examples

See `~/.config/yadm/examples/` for template `.local` files:

- `zshrc.local.linux` - Linux-specific zsh settings (Manjaro config, Linux paths)
- `bootstrap.local.macos` - macOS bootstrap with Homebrew

## Setup on a New Machine

1. Clone yadm repo: `yadm clone <repo-url>`
2. Run bootstrap: `yadm bootstrap`
3. Copy appropriate example to `.local` file:
   - **Linux**: `cp ~/.config/yadm/examples/zshrc.local.linux ~/.zshrc.local`
   - **macOS**: `cp ~/.config/yadm/examples/bootstrap.local.macos ~/.config/yadm/bootstrap.local`
4. Edit `.local` files for machine-specific customization

## Current Machine

- **OS**: macOS (Darwin)
- **Hostname**: abishnoi-mlt
- **User**: abishnoi
