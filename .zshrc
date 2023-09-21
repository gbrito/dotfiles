# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.dotfiles/bin:$HOME/.local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(ssh-agent git web-search zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

export LANG=en_US.UTF-8
export _JAVA_AWT_WM_NONREPARENTING=1

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# Load seperated config files
for conf in "$HOME/.dotfiles/work/"*; do
  source "${conf}"
done
unset conf

for conf in "$HOME/.dotfiles/zshconf/"*; do
  source "${conf}"
done
unset conf

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc
