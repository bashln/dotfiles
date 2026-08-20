local wezterm = require("wezterm")
local config = wezterm.config_builder()

local function get_home_dir()
	return wezterm.home_dir or os.getenv("HOME") or os.getenv("USERPROFILE")
end

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

-- home_dir disponível para uso quando necessário

-- ============================================================================
-- BASE: Linux / WSLg (ambiente canonico)
-- Tudo abaixo e o padrao. Windows so sobrescreve no final se necessario.
-- ============================================================================

-- ===== Keybindings =====
config.keys = {
	{ key = "F12", mods = "NONE", action = wezterm.action.ActivateCommandPalette },
	{ key = "UpArrow", mods = "ALT", action = wezterm.action.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "ALT", action = wezterm.action.ScrollToPrompt(1) },
	{ key = "x", mods = "ALT", action = wezterm.action.ActivateCopyMode },
	{ key = "s", mods = "ALT|SHIFT", action = wezterm.action.SplitVertical },
	{ key = "v", mods = "ALT|SHIFT", action = wezterm.action.SplitHorizontal },
	{ key = "LeftArrow", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "CTRL", action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "w", mods = "ALT|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
}

-- ===== Command Palette =====
local act = wezterm.action

wezterm.on("augment-command-palette", function(window, pane)
	return {
		{
			brief = "Rename tab",
			icon = "md_rename_box",
			action = act.PromptInputLine({
				description = "Enter new name for tab",
				initial_value = window:active_tab():get_title(),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}
end)

-- ===== Fontes e Cores =====
config.font_size = 10
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Terminess Nerd Font Mono",
	"BlexMono Nerd Font Mono",
})

config.force_reverse_video_cursor = true
config.color_scheme = "Eldritch"

-- ===== Renderizacao =====
config.enable_wayland = true
config.front_end = "OpenGL"

-- ===== Janela / UI =====
-- NONE: borderless (pode dificultar resize/minimize)
-- RESIZE: sem titulo, com borda redimensionavel
-- TITLE | RESIZE: padrao com titulo e borda
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.use_resize_increments = false
config.adjust_window_size_when_changing_font_size = false
config.prefer_to_spawn_tabs = false

-- ===== Background =====
-- Path simples e direto - não depende do nome do arquivo de config
local bg_path = (os.getenv("HOME") or "") .. "/.config/wezterm/bg-blurred.png"

if file_exists(bg_path) then
	config.window_background_image = bg_path
	config.window_background_opacity = 1.00
end

-- ============================================================================
-- OVERRIDE: Windows (excecoes pontuais)
-- ============================================================================
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.window_decorations = "RESIZE"
	config.initial_rows = 35
	config.initial_cols = 120

	-- config.window_background_image = nil

	local candidates = {
		"C:\\Program Files\\Git\\usr\\bin\\bash.exe",
		"C:\\Program Files\\Git\\bin\\bash.exe",
		"C:\\Program Files (x86)\\Git\\usr\\bin\\bash.exe",
		"C:\\Program Files (x86)\\Git\\bin\\bash.exe",
	}

	local shell
	for _, p in ipairs(candidates) do
		if file_exists(p) then
			shell = p
			break
		end
	end

	if not shell then
		config.default_prog = { "powershell.exe", "-NoLogo" }
	else
		if shell:match("git%-bash%.exe$") then
			config.default_prog = { shell }
		else
			config.default_prog = { shell, "--login", "-i" }
		end
	end

	config.default_cwd = os.getenv("USERPROFILE") or "C:\\"
end

return config
