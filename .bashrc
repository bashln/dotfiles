# Omarchy environment (OMARCHY_PATH + PATH), needed even for non-interactive shells
[[ -r /usr/share/omarchy/default/bash/env-bootstrap ]] && source /usr/share/omarchy/default/bash/env-bootstrap

# If not running interactively, don't do anything else (leave this above the rc source)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source "$OMARCHY_PATH/default/bash/rc"

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# ------------------------------------------------------------------
# Dotfiles (bare repo)
# ------------------------------------------------------------------
alias dotfiles='git --git-dir="$HOME/.dotfiles-bare" --work-tree="$HOME"'

# ------------------------------------------------------------------
# PATH
# ------------------------------------------------------------------
for p in "$HOME/.local/bin" "$HOME/bin" "$HOME/go/bin" "$HOME/.cargo/bin" "/usr/local/bin" "$HOME/.npm-global/bin" "/opt/nvim-linux-x86_64/bin"; do
  [ -d "$p" ] && PATH="$p:$PATH"
done

# ------------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------------
export EDITOR=nvim
export DOOMDIR="$HOME/.config/doom"
export NODE_OPTIONS=--no-deprecation

# Qt/GTK dark theme
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_THEME="Adwaita:dark"

# ------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------

# LS (eza)
if command -v eza &>/dev/null; then
  alias ls='eza -al --color=always --group-directories-first --icons'
  alias la='eza -a  --color=always --group-directories-first --icons'
  alias ll='eza -l  --color=always --group-directories-first --icons'
  alias lt='eza -aT --color=always --group-directories-first --icons'
  alias l.='eza -a | grep -e "^\\."'
fi

# Editors
alias v='nvim'
alias vim='nvim'
alias nvima='NVIM_APPNAME=astronvim nvim'
alias bv='NVIM_APPNAME=bash-nvim nvim'
alias nviml='NVIM_APPNAME=lazyvim nvim'

# System helpers (dnf — Arch/ Fedora compat)
alias update='sudo dnf upgrade --refresh'
alias install='sudo dnf install'
alias search='dnf search'
alias remove='sudo dnf remove'
alias cleanup='sudo dnf autoremove -y'
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
alias srcfish='source ~/.config/fish/config.fish'
alias exithypr='hyprctl dispatch exit'
alias doomsync='$HOME/.config/emacs/bin/doom sync'
alias doomupd='$HOME/.config/emacs/bin/doom upgrade'

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
  sudo dnf autoremove -y
}

# ------------------------------------------------------------------
# Initializations
# ------------------------------------------------------------------

# Homebrew (Linux)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
  alias cd='z'
fi
