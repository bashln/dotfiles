# dotfiles

Repositório de dotfiles pessoais. Instalado via **GNU Stow** (ou fallback manual via `install.sh`).

## Stack

- **Shell**: Zsh (default) + Fish
- **WM**: Hyprland (principal), Niri (secundário)
- **Bar/Launcher**: Waybar, Rofi, Walker
- **Terminais**: Alacritty, Kitty, Ghostty
- **Editor**: Neovim (LazyVim / AstroNvim / bash-nvim)
- **Outros**: Yazi (file manager), Doom Emacs (ocasional)

## Estrutura

```
.
├── home/                      # Pacote Stow (prefixo vira ~/)
│   ├── .bashrc
│   ├── .zshrc
│   ├── .agents/               # Skills/agents
│   ├── .config/
│   │   ├── alacritty/
│   │   ├── fish/
│   │   ├── hypr/
│   │   ├── kitty/
│   │   ├── nvim/
│   │   ├── opencode/
│   │   └── waybar/
│   └── .gemini/               # Gemini CLI config
├── install.sh                 # Bootstrap (stow + fallback symlink)
└── .gitignore
```

`home/<path>` → `~/<path>` via `stow -t $HOME -S home`.

## Requisitos

- Linux (testado em Fedora)
- `git`, `stow` (Fedora: `sudo dnf install stow`)

## Instalação rápida

```bash
git clone https://github.com/bashln/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

O script:
1. Cria symlinks via `stow` (ou fallback manual se stow não estiver disponível)
2. Configura zsh como shell default (instala via `dnf` se faltar)
3. Backup automático de arquivos conflitantes (`*.backup.YYYYMMDDHHMMSS`)

## Workflow

```bash
# Editar config
vim ~/dotfiles/home/.config/hypr/bindings.conf

# Reaplicar (atualiza os symlinks)
cd ~/dotfiles && stow -t $HOME -S home

# Ou usar o install.sh (mais robusto, faz backup)
./install.sh
```

## Convenções

- **Package manager**: aliases usam `dnf` (Fedora). Ver `home/.zshrc`, `home/.config/fish/config.fish`, `home/.bashrc`.
- **Configurações sensíveis** (`.ssh`, `.gnupg`, `.aws`, chaves, `fish_variables`): **nunca** commitadas (ver `.gitignore`).
- **Opencode plugins locais** (`aft.json`, `magic-context.jsonc`): migradas para `~/.config/cortexkit/` (shared location).

## Remotes

- `origin`: github.com/bashln/dotfiles
- `gitlab`: gitlab.com/bashln/dotfiles
