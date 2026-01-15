# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.dotfiles/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

_discover_ssh_keys() {
    setopt local_options null_glob
    local keys=()
    for key in ~/.ssh/id_*; do
        [ -f "$key" ] || continue
        [[ "$key" == *.pub ]] && continue
        keys+=(${key#$HOME/.ssh/})
    done
    for dir in ~/.ssh/*/; do
        [ -d "$dir" ] || continue
        for key in ${dir}id_*; do
            [ -f "$key" ] || continue
            [[ "$key" == *.pub ]] && continue
            keys+=(${key#$HOME/.ssh/})
        done
    done
    echo "${keys[@]}"
}

zstyle :omz:plugins:ssh-agent identities $(_discover_ssh_keys)

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git ssh-agent web-search zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

export GPG_TTY=$(tty)
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
