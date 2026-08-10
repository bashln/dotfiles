# Wezterm Configuration Analysis

## Overview

This repository contains the Wezterm terminal emulator configuration for a Windows/Linux hybrid setup. The configuration focuses on providing a tmux-like experience with custom key bindings, font fallback chain, and platform-specific optimizations for both Niri (Linux) and Windows environments.

## Structure

```
wezterm/
├── wezterm.lua              # Main configuration (162 lines)
├── constants.lua            # Background image paths (12 lines)
├── colors/
│   └── dank-theme.toml      # Color scheme
├── lua/
│   └── rose-pine.lua        # Rose Pine theme
├── commands/
│   ├── toggle-transparency.lua  # Transparency toggle command
│   └── ini.lua              # Command initializer
├── assets/
│   ├── bg-blurred.png
│   ├── bg-blurred-w11.png
│   ├── bg-blurred-darker.png
│   └── bg-blurred-darker-w11.png
└── bg-blurred.png           # Root copy of background
```

## Hotspots

1. **Key Bindings** - Currently defines F12 for command palette, ALT+Up/Down for prompt navigation, and ALT+x for copy mode (lines 7-12 in wezterm.lua)
2. **Font Configuration** - Defines an 8-font fallback chain with Nerd Font support for proper icon rendering (lines 16-25)
3. **Background Image Loading** - Platform-specific logic that checks for existence of blurred background images and applies them (lines 43-53, 107-117)
4. **Window Decorations** - Different configurations for Linux (NONE) vs Windows (RESIZE) to work with window managers like Niri (lines 59-60, 88-89, 93)
5. **Shell Configuration** - Git Bash detection with PowerShell fallback on Windows, including login shell configuration (lines 120-146)

## Risks

1. **Hardcoded paths in constants.lua** - Uses `$HOME` environment variable which doesn't work on Windows (Windows uses `%USERPROFILE%`), potentially breaking background image loading
2. **Fragile string replacement for background path** - `cfg:gsub("wezterm.lua", "bg-blurred.png")` assumes standard file naming and could fail if config file path has unusual formatting or if WEZTERM_CONFIG_FILE is set differently
3. **Unused color themes** - dank-theme.toml and rose-pine.lua exist in the repository but are never loaded, creating maintenance overhead
4. **Platform-specific code duplication** - Background loading logic appears twice (lines 43-53 and 107-117) with slight variations, increasing maintenance burden

## Invariants

Invariants not formally defined in the current configuration. However, based on the code, these should hold true:

1. The configuration must always define a valid color scheme (currently "Dracula (Official)" on line 160)
2. The F12 key must always trigger the command palette (line 8)
3. Font fallback chain must contain at least one Nerd Font for proper icon display
4. On Windows, either Git Bash or PowerShell must be available as the default shell

## Recommended Next Steps

1. **Add tmux-like key bindings**: Implement split pane shortcuts (Ctrl+Shift+Arrows for splitting, Alt+Arrows for navigation)
2. **Fix platform detection**: Replace `$HOME` with platform-agnostic path detection using `wezterm.home_dir`
3. **Modularize configuration**: Split wezterm.lua into logical sections (keybinds.lua, appearance.lua, platform.lua)
4. **Load unused themes**: Implement theme switching capability to utilize dank-theme.toml and rose-pine.lua
5. **Add validation**: Verify required fonts exist at startup and fall back gracefully
6. **Remove commented code**: Clean up experimental/commented sections to improve readability
7. **Create key binding documentation**: Add a comment block explaining all key bindings for reference
