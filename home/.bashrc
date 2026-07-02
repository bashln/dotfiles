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

# 7-Zip
alias enc7z='7zz a -t7z -p -mhe=on'
alias dec7z='7zz x -p'

# System helpers (dnf — Fedora)
alias update='sudo dnf upgrade --refresh -y'
alias install='sudo dnf install -y'
alias search='dnf search'
alias remove='sudo dnf remove -y'
alias cleanup='sudo dnf autoremove -y'

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      . "$rc"
    fi
  done
fi
unset rc

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"


# Added by Antigravity CLI installer
export PATH="/home/bashln/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
