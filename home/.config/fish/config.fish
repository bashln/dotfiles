# ==========================================================
# Fish Config — CachyOS (Arch Based)
# SysAdmin: Linux | Data: 2025
# ==========================================================

# ----------------------------------------------------------
# 0) Verificação de Interatividade
# ----------------------------------------------------------
if status is-interactive

    # ----------------------------------------------------------
    # 1) PATHs e Variáveis de Ambiente
    # ----------------------------------------------------------
    fish_add_path $HOME/.local/bin
    fish_add_path $HOME/bin
    fish_add_path $HOME/go/bin
    fish_add_path $HOME/.cargo/bin
    fish_add_path /usr/local/bin
    fish_add_path $HOME/.npm-global/bin

    # Neovim manual (se existir, embora no Arch usemos o do repo geralmente)
    if test -d /opt/nvim-linux-x86_64/bin
        fish_add_path /opt/nvim-linux-x86_64/bin
    end

    # Editor Padrão
    set -gx EDITOR nvim

    # Doom Emacs no layout atual via stow
    set -gx DOOMDIR "$HOME/.config/doom"

    # ----------------------------------------------------------
    # 2) Configurações Nativas do Fish
    # ----------------------------------------------------------
    set -U fish_greeting ""
    set -gx NODE_OPTIONS --no-deprecation

    # ----------------------------------------------------------
    # 3) Ferramentas Modernas
    # ----------------------------------------------------------

    # Starship
    if type -q starship
        starship init fish | source
    end

    # Zoxide
    if type -q zoxide
        zoxide init fish | source
        alias cd='z'
    end

    # Node.js (fnm)
    set -gx FNM_PATH "$HOME/.local/share/fnm"
    fish_add_path $FNM_PATH
    if type -q fnm
        fnm env --use-on-cd | source
    end

    # fzf
    if type -q fzf
        fzf --fish | source
    end

    # ----------------------------------------------------------
    # 4) Aliases e Abreviações
    # ----------------------------------------------------------

    # --- LS (eza) ---
    if type -q eza
        alias ls='eza -al --color=always --group-directories-first --icons'
        alias la='eza -a  --color=always --group-directories-first --icons'
        alias ll='eza -l  --color=always --group-directories-first --icons'
        alias lt='eza -aT --color=always --group-directories-first --icons'
        alias l.='eza -a | grep -e "^\."'
    end

    # --- Git ---
    abbr --add gs 'git status'
    abbr --add ga 'git add -A'
    abbr --add gc 'git commit -m'
    abbr --add gp 'git push'
    abbr --add gl 'git pull'
    abbr --add gco 'git checkout'
    abbr --add clone 'git clone'
    abbr --add lz lazygit

    # --- Navegação ---
    abbr --add .. 'cd ..'
    abbr --add ... 'cd ../..'
    abbr --add .... 'cd ../../..'

    abbr --add cdg 'cd ~/.config'
    abbr --add cddev 'cd ~/bashln/'
    abbr --add cdprojeto 'cd ~/bashln/projeto-mercado'

    # --- Editores ---
    alias v='nvim'
    alias vim='nvim'

    abbr --add nkitty 'nvim ~/.config/kitty/kitty.conf'
    abbr --add nalac 'nvim ~/.config/alacritty/alacritty.toml'
    abbr --add nwez 'nvim ~/.config/wezterm/wezterm.lua'
    abbr --add nzsh 'nvim ~/.zshrc'
    abbr --add nfish 'nvim ~/.config/fish/config.fish'
    abbr --add ngho 'nvim ~/.config/ghostty/config'

    # Ambientes Neovim
    alias nvima='NVIM_APPNAME=astronvim nvim'
    alias bv='NVIM_APPNAME=bash-nvim nvim'
    alias nviml='NVIM_APPNAME=lazyvim nvim'

    # --- Sistema (PACMAN / ARCH) ---
    # Anatomia: -S (Sync), -y (Refresh DB), -u (Sys Upgrade)

    abbr --add update 'sudo pacman -Syu --noconfirm'
    abbr --add install 'sudo pacman -S --noconfirm --needed'
    abbr --add search 'pacman -Ss'

    # Remoção Segura e Recursiva
    # -R (Remove), -s (Recursive/Dependencies), -n (No backup files)
    abbr --add remove 'sudo pacman -Rsn'

    # Limpeza de Orfãos (Equivalente ao autoremove)
    # Qtdq: Query, deps não requeridas (t), deps de deps (d), quiet (q)
    function cleanup
        set orphans (pacman -Qtdq)
        if test (count $orphans) -gt 0
            sudo pacman -Rsn $orphans
            echo "Removidos $orphans"
        else
            echo "Nenhum órfão encontrado."
        end
    end

    # Logs do sistema
    abbr --add jctl 'journalctl -p 3 -xb'

    # Compressão (Usage: tarnow archive.tar file1 file2)
    alias tarnow='tar -acf '
    alias untar='tar -zxvf '

    # --- Pessoais ---
    # Chezmoi: importa alterações do ~/.config/ para o source directory
    function chezmoi-import
        set dirs alacritty doom fish ghostty kitty neovide nvim opencode picom qtile rofi-bashln waybar wezterm yazi
        for dir in $dirs
            if test -d "$HOME/.config/$dir"
                chezmoi add "$HOME/.config/$dir"
            end
        end
        # Re-add para sincronizar deleções
        chezmoi re-add
    end

    abbr --add srcfish 'source ~/.config/fish/config.fish'
    abbr --add cdaula 'cd ~/gitlab/maisPraTi/'
    abbr --add exithypr 'hyprctl dispatch exit'
    abbr --add ask gemini
    abbr --add vpninova 'sudo openvpn --config ~/Downloads/sslvpn-itinerario@inova.local-client-config.ovpn --daemon'
    abbr --add doomsync '$HOME/.config/emacs/bin/doom sync'
    abbr --add doomupd '$HOME/.config/emacs/bin/doom upgrade'
    abbr --add dotsize 'du -sh .git && git count-objects -vH'
    abbr --add cl clear
    abbr --add mnti 'sudo mount -t drvfs I: /mnt/i'
    abbr --add mntc 'sudo mount -t drvfs C: /mnt/c'
    abbr --add cdc 'cd /mnt/c'
    abbr --add cdi 'cd /mnt/i'

    abbr --add ralph 'distrobox enter ralph-loop'

    # --- AI Loop ---
    abbr --add ai-bug 'bash ~/.config/opencode/scripts/ai-loop.sh once linear-bug-finding'
    abbr --add ai-sec 'bash ~/.config/opencode/scripts/ai-loop.sh once security-review'
    abbr --add ai-deps 'bash ~/.config/opencode/scripts/ai-loop.sh once dependency-audit'
    abbr --add ai-qa 'bash ~/.config/opencode/scripts/ai-loop.sh once qa-review'
    abbr --add ai-loop 'bash ~/.config/opencode/scripts/ai-loop.sh loop'
    abbr --add ai-status 'bash ~/.config/opencode/scripts/ai-loop.sh status'
    abbr --add ai-dry 'DRY_RUN=true bash ~/.config/opencode/scripts/ai-loop.sh once'
    abbr --add ai-cron 'bash ~/.config/opencode/scripts/ai-loop.sh cron-install'
    abbr --add ai-cron-rm 'bash ~/.config/opencode/scripts/ai-loop.sh cron-remove'
    abbr --add ai-improve 'bash ~/.config/opencode/scripts/ai-loop.sh improve'
    abbr --add ai-timed 'bash ~/.config/opencode/scripts/ai-loop.sh timed'

    # ----------------------------------------------------------
    # 5) Funções
    # ----------------------------------------------------------

    function log
        set -l cmd $argv
        set -l ts (date +%Y%m%d-%H%M%S)
        eval $cmd 2>&1 | tee "$ts.log"
    end

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function fopen
        set -l root "."
        if test -n "$argv[1]"
            set root "$argv[1]"
        end
        fd -t f -H -0 . "$root" | fzf --read0 --multi --select-1 --exit-0 \
            --bind 'enter:execute-silent(xdg-open {+})+abort' \
            --prompt='files> '
    end

end

function pom
    set split $POMO_SPLIT
    if ! test -n "$split"
        set split $(gum choose "25/5" "50/10" "all done" --header "Choose a pomodoro split.")
    end

    switch $split
        case 25/5
            set work 25m
            set break 5m
        case 50/10
            set work 50m
            set break 10m
        case 'all done'
            return
    end

    timer $work && terminal-notifier -message Pomodoro \
        -title 'Work Timer is up! Take a Break 😊' \
        -sound Crystal

    gum confirm "Ready for a break?" && timer $break && terminal-notifier -message Pomodoro \
        -title 'Break is over! Get back to work 😬' \
        -sound Crystal \
        || pom
end

# opencode
fish_add_path $HOME/.opencode/bin

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Added by Antigravity CLI installer
set -gx PATH "/home/bashln/.local/bin" $PATH
