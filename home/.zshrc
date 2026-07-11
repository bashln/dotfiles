# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile

HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch notify
bindkey -e
# End of lines configured by zsh-newuser-install

# pacman aliases
alias p='sudo pacman'
alias pi='sudo pacman -S'
alias pu='sudo pacman -Syu'
alias pr='sudo pacman -Rns'
alias ps='pacman -Ss'
alias pq='pacman -Qs'
alias pqi='pacman -Qi'
alias pcc='sudo pacman -Sc'
alias pown='pacman -Qo'
