# Dotfiles

Public Arch Linux package inventory and personal desktop configuration.

## Install

Run as a regular user on an Arch Linux x86_64 installation:

```bash
git clone https://github.com/gbrito/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

The installer updates the system, enables `multilib`, installs repository and
AUR packages, deploys symlinks, and installs shell, tmux, and Neovim plugins.
Existing configuration paths are moved to a timestamped directory under
`~/.local/state/dotfiles/backups/` before linking.

Preview without changing the system:

```bash
~/.dotfiles/install.sh --dry-run
```

Deploy only the configuration without installing or updating packages. This may
request sudo access when system-wide configuration needs updating:

```bash
~/.dotfiles/install.sh --link-only
```
