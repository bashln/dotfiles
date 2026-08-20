# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile

HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(
  git
  zsh-autosuggestions
  history-substring-search
  zsh-syntax-highlighting
)

export ZSH="$HOME/.oh-my-zsh"

source $ZSH/oh-my-zsh.sh

# ------------------------------------------------------------------
# Fish-like autosuggestions
# ------------------------------------------------------------------
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^ ' autosuggest-accept   # Ctrl+Space aceita sugestão
bindkey '^]' autosuggest-execute  # Ctrl+] executa sugestão diretamente

# ------------------------------------------------------------------
# Fish-like completion
# ------------------------------------------------------------------
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both

# ------------------------------------------------------------------
# Fish-like history search (up/down on partial match)
# ------------------------------------------------------------------
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ------------------------------------------------------------------
# PATH
# ------------------------------------------------------------------
for p in "$HOME/.local/bin" "$HOME/bin" "$HOME/go/bin" "$HOME/.cargo/bin" "/usr/local/bin" "$HOME/.npm-global/bin" "/opt/nvim-linux-x86_64/bin"; do
  [ -d "$p" ] && PATH="$p:$PATH"
done
PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------
export EDITOR=nvim
export DOOMDIR="$HOME/.config/doom"
export NODE_OPTIONS=--no-deprecation

# ------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------

# Editors
alias v='nvim'
alias vim='nvim'
alias e='emacs'
alias nvima='NVIM_APPNAME=astronvim nvim'
alias bv='NVIM_APPNAME=bash-nvim nvim'
alias nviml='NVIM_APPNAME=lazyvim nvim'
alias nconf='nvim ~/.zshrc'
alias src='source ~/.zshrc'

# System helpers (pacman — CachyOS)
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -Rns'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null; paru -c 2>/dev/null; true'
alias jctl='journalctl -p 3 -xb'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cdg='cd ~/.config'
alias cddev='cd ~/'

# Git
alias gs='git status'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias clone='git clone'
alias lz='lazygit'

# Misc
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias dotsize='du -sh .git && git count-objects -vH'
alias cl='clear'
alias ask='gemini'

# 7-Zip
alias enc7z='7zz a -t7z -p -mhe=on'
alias dec7z='7zz x -p'

# ------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------
log() {
  local cmd="$*"
  local ts
  ts=$(date +%Y%m%d-%H%M%S)
  eval "$cmd" 2>&1 | tee "$ts.log"
}

cleanup-orphans() {
  sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || true
  paru -c 2>/dev/null || true
}

doomsync() {
  if [ -x "$HOME/.config/emacs/bin/doom" ]; then
    "$HOME/.config/emacs/bin/doom" sync
  else
    echo "doom not found at $HOME/.config/emacs/bin/doom"
  fi
}

doomupd() {
  if [ -x "$HOME/.config/emacs/bin/doom" ]; then
    "$HOME/.config/emacs/bin/doom" upgrade
  else
    echo "doom not found at $HOME/.config/emacs/bin/doom"
  fi
}

# ------------------------------------------------------------------
# Initializations
# ------------------------------------------------------------------

# Homebrew (Linux)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

eval "$(starship init zsh)"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Android SDK
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# zoxide (kept last — zoxide recommends being at the end of the file)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"


# Added by Antigravity CLI installer
export PATH="/home/bashln/.local/bin:$PATH"
