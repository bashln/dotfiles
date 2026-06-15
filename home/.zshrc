# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions history-substring-search zsh-syntax-highlighting z extract command-not-found)

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

# Homebrew (Linux)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Source system zsh plugins (autosuggestions, syntax-highlighting)
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

export PATH="$HOME/.npm-global/bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Android SDK Configuration
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

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

# ------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------

# Toolbox shortcuts
alias dev='toolbox run -c dev'
alias deventer='toolbox enter -c dev'
alias devinstall='toolbox run -c dev sudo dnf install -y'
alias devsearch='toolbox run -c dev dnf search'
alias devop='toolbox run -c dev opencode'
alias devnvim='toolbox run -c dev nvim'
alias devemacs='toolbox run -c dev emacs'

# Toolbox leo
alias leo='toolbox run -c leo'
alias leoenter='toolbox enter -c leo'
alias leoinstall='toolbox run -c leo sudo dnf install -y'

# Sandbox containers
alias ralphbox='podman run --rm -it \
  --name ralph-sandbox \
  --user root \
  --security-opt=no-new-privileges \
  --cap-drop=ALL \
  --pids-limit=512 \
  --memory=4g \
  --cpus=4 \
  --tmpfs /tmp:rw,nosuid,nodev,size=2g \
  --tmpfs /run:rw,nosuid,nodev,size=128m \
  -v "$PWD:/workspace:rw,Z" \
  -w /workspace \
  docker.io/oven/bun:latest \
  bash'

# Editors
alias v='nvim'
alias vim='nvim'
alias e='emacs'
alias nvima='NVIM_APPNAME=astronvim nvim'
alias bv='NVIM_APPNAME=bash-nvim nvim'
alias nviml='NVIM_APPNAME=lazyvim nvim'
alias nbash='nvim ~/.bashrc'
alias nconf='nvim ~/.zshrc'
alias src='source ~/.zshrc'

# System helpers (Fedora/dnf via toolbox)
alias update='toolbox run -c dev sudo dnf upgrade -y'
alias install='toolbox run -c dev sudo dnf install -y'
alias search='toolbox run -c dev dnf search'
alias remove='toolbox run -c dev sudo dnf remove -y'
alias cleanup='toolbox run -c dev sudo dnf autoremove -y'
alias jctl='journalctl -p 3 -xb'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cdg='cd ~/.config'
alias cddev='cd ~/'

# Git shorthands
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
  toolbox run -c dev sudo dnf autoremove -y
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

# zoxide (if available)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

eval "$(starship init zsh)"
export PATH="$HOME/.local/bin:$PATH"
