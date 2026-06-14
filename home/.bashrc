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

# Secure wrapper functions to run AI CLI tools under the 'aiagent' user
agy() {
    sudo -i -u aiagent agy "$@"
}
codex() {
    sudo -i -u aiagent codex "$@"
}
opencode() {
    sudo -i -u aiagent opencode "$@"
}
