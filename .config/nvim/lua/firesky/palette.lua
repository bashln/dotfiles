local M = {}

-- Base palette strictly matching colors.toml from omarchy-firesky-theme
M.raw = {
	mode = "dark",

	accent = "#2a7a80",
	selection = "#1e1e1e",
	muted = "#585553",

	background = "#0f0f0f",
	dark_background = "#0a0a0a",
	darker_background = "#050505",
	lighter_background = "#1e1e1e",

	foreground = "#e0d8d0",
	dark_foreground = "#b7a593",
	light_foreground = "#e8e2dc",
	bright_foreground = "#f4f2ef",

	red = "#e6441a",
	yellow = "#e68040",
	orange = "#e6622d",
	green = "#1a6b6e",
	cyan = "#40b8b4",
	blue = "#2a7a80",
	magenta = "#c4753d",
	brown = "#852c15",

	bright_red = "#e66b40",
	bright_yellow = "#e6a052",
	bright_green = "#40c4c0",
	bright_cyan = "#70e0dd",
	bright_blue = "#52c9cd",
	bright_magenta = "#e6b375",
}

function M.get(overrides)
	local p = M.raw

	local semantic = {
		-- Base editor background & foreground
		bg = p.background,
		fg = p.foreground,
		background = p.background,
		foreground = p.foreground,

		-- Extended background variants
		bg_dark = p.dark_background,
		bg_darker = p.darker_background,
		bg_light = p.lighter_background,
		bg_alt = p.dark_background,
		bg_highlight = "#182224", -- Subtle sky-dark highlight
		bg_visual = "#1e2e30",    -- Noticeable yet harmonious visual selection
		border = p.blue,

		-- Text variants
		fg_dark = p.dark_foreground,
		fg_light = p.light_foreground,
		fg_bright = p.bright_foreground,
		fg_muted = p.muted,

		-- Core theme accents
		accent = p.accent,
		selection_bg = "#23393b",
		selection_fg = p.bright_foreground,

		-- Syntax roles
		comment = "#6d7877",       -- Readable muted teal-tinted gray
		comment_alt = p.muted,
		keyword = p.magenta,       -- Warm fire ember: #c4753d
		conditional = p.magenta,
		func = p.cyan,             -- Sky cyan: #40b8b4
		func_builtin = p.bright_cyan,
		string = p.bright_green,   -- Aurora/teal green: #40c4c0
		string_escape = p.bright_cyan,
		type = p.yellow,           -- Fire amber: #e68040
		constant = p.yellow,
		number = p.orange,         -- Fiery orange: #e6622d
		boolean = p.orange,
		variable = p.foreground,
		property = p.light_foreground,
		operator = p.bright_cyan,
		punctuation = p.dark_foreground,

		-- UI & Git
		cursor = p.bright_red,
		cursor_text = p.darker_background,
		line_number = p.muted,
		line_number_active = p.bright_foreground,

		git_add = p.bright_green,
		git_change = p.yellow,
		git_delete = p.red,
		git_ignore = p.muted,

		-- Diagnostics
		error = p.red,
		warning = p.yellow,
		info = p.cyan,
		hint = p.bright_blue,

		-- Terminal palette (16 colors)
		terminal_black = p.dark_background,
		terminal_red = p.red,
		terminal_green = p.green,
		terminal_yellow = p.yellow,
		terminal_blue = p.blue,
		terminal_magenta = p.magenta,
		terminal_cyan = p.cyan,
		terminal_white = p.foreground,

		terminal_bright_black = p.muted,
		terminal_bright_red = p.bright_red,
		terminal_bright_green = p.bright_green,
		terminal_bright_yellow = p.bright_yellow,
		terminal_bright_blue = p.bright_blue,
		terminal_bright_magenta = p.bright_magenta,
		terminal_bright_cyan = p.bright_cyan,
		terminal_bright_white = p.bright_foreground,

		none = "NONE",
	}

	local colors = vim.tbl_extend("force", p, semantic)

	if overrides and type(overrides) == "table" then
		colors = vim.tbl_deep_extend("force", colors, overrides)
	end

	return colors
end

return M
