# .bashrc
# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc

export PATH=~/.npm-global/bin:$PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Android SDK Configuration
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH

# ------------------------------------------------------------------
# Aliases and helpers
# ------------------------------------------------------------------

# Ensure common user paths are early in PATH if they exist
for p in "$HOME/.local/bin" "$HOME/bin" "$HOME/go/bin" "$HOME/.cargo/bin" "/usr/local/bin" "$HOME/.npm-global/bin" "/opt/nvim-linux-x86_64/bin"; do
  if [ -d "$p" ]; then
    PATH="$p:$PATH"
  fi
done

# Editor and common envs
export EDITOR=nvim
export DOOMDIR="$HOME/.config/doom"
export NODE_OPTIONS=--no-deprecation

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
alias nconf='nvim ~/.bashrc'
alias src='source ~/.bashrc'

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

# Functions
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
  eval "$(zoxide init bash)"
  alias cd='z'
fi

eval "$(starship init bash)"
export PATH="$HOME/.local/bin:$PATH"
