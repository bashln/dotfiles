local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(config)
	local palette = require("firesky.palette")
	local colors = palette.get(config.colors)

	-- Transparent background support
	if config.disable and config.disable.background then
		colors.bg = "NONE"
		colors.bg_alt = "NONE"
	end

	-- Editor Highlights
	hl("Normal", { fg = colors.fg, bg = colors.bg })
	hl("NormalFloat", { fg = colors.fg, bg = colors.bg_dark })
	hl("FloatBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("FloatTitle", { fg = colors.bright_cyan, bg = colors.bg_dark, bold = true })
	hl("ColorColumn", { bg = colors.bg_alt })
	hl("Cursor", { fg = colors.cursor_text, bg = colors.cursor })
	hl("CursorLine", { bg = colors.bg_highlight })
	hl("CursorColumn", { bg = colors.bg_highlight })
	hl("LineNr", { fg = colors.line_number })
	hl("CursorLineNr", { fg = colors.line_number_active, bold = true })
	hl("SignColumn", { bg = colors.bg })
	hl("StatusLine", { fg = colors.fg, bg = colors.bg_dark })
	hl("StatusLineNC", { fg = colors.comment, bg = colors.bg_dark })
	hl("TabLine", { fg = colors.comment, bg = colors.bg_dark })
	hl("TabLineFill", { bg = colors.bg_darker })
	hl("TabLineSel", { fg = colors.fg_bright, bg = colors.bg, bold = true })
	hl("VertSplit", { fg = colors.bg_light })
	hl("WinSeparator", { fg = colors.bg_light })
	hl("Visual", { bg = colors.bg_visual, fg = colors.selection_fg })
	hl("VisualNOS", { bg = colors.bg_visual, fg = colors.selection_fg })
	hl("Search", { fg = colors.darker_background, bg = colors.func })
	hl("IncSearch", { fg = colors.darker_background, bg = colors.bright_yellow, bold = true })
	hl("CurSearch", { fg = colors.darker_background, bg = colors.bright_yellow, bold = true })
	hl("Substitute", { fg = colors.darker_background, bg = colors.orange })
	hl("MatchParen", { fg = colors.bright_red, bg = colors.bg_highlight, bold = true })
	hl("Question", { fg = colors.info })
	hl("ModeMsg", { fg = colors.fg, bold = true })
	hl("MoreMsg", { fg = colors.info })
	hl("ErrorMsg", { fg = colors.error, bold = true })
	hl("WarningMsg", { fg = colors.warning, bold = true })
	hl("Pmenu", { fg = colors.fg, bg = colors.bg_dark })
	hl("PmenuSel", { fg = colors.fg_bright, bg = colors.bg_highlight, bold = true })
	hl("PmenuSbar", { bg = colors.bg_dark })
	hl("PmenuThumb", { bg = colors.border })
	hl("WildMenu", { fg = colors.fg_bright, bg = colors.bg_highlight })
	hl("Folded", { fg = colors.comment, bg = colors.bg_alt })
	hl("FoldColumn", { fg = colors.comment, bg = colors.bg })
	hl("Directory", { fg = colors.cyan, bold = true })
	hl("Title", { fg = colors.keyword, bold = true })
	hl("NonText", { fg = colors.comment })
	hl("SpecialKey", { fg = colors.comment })
	hl("Whitespace", { fg = colors.comment })
	hl("EndOfBuffer", { fg = colors.bg })
	hl("Conceal", { fg = colors.comment })
	hl("SpellBad", { sp = colors.error, undercurl = true })
	hl("SpellCap", { sp = colors.warning, undercurl = true })
	hl("SpellLocal", { sp = colors.info, undercurl = true })
	hl("SpellRare", { sp = colors.hint, undercurl = true })

	-- Standard Syntax Highlighting
	local comment_opts = { fg = colors.comment }
	if not (config.disable and config.disable.italic_comments) then
		comment_opts.italic = true
	end
	hl("Comment", comment_opts)
	hl("Todo", { fg = colors.bright_yellow, bold = true })
	hl("Constant", { fg = colors.constant })
	hl("String", { fg = colors.string })
	hl("Character", { fg = colors.string })
	hl("Number", { fg = colors.number })
	hl("Float", { fg = colors.number })
	hl("Boolean", { fg = colors.boolean })
	hl("Identifier", { fg = colors.variable })
	hl("Function", { fg = colors.func })
	hl("Statement", { fg = colors.keyword })
	hl("Conditional", { fg = colors.conditional, bold = true })
	hl("Repeat", { fg = colors.keyword, bold = true })
	hl("Label", { fg = colors.type })
	hl("Operator", { fg = colors.operator })
	hl("Keyword", { fg = colors.keyword })
	hl("Exception", { fg = colors.error })
	hl("PreProc", { fg = colors.keyword })
	hl("Include", { fg = colors.keyword })
	hl("Define", { fg = colors.keyword })
	hl("Macro", { fg = colors.keyword })
	hl("PreCondit", { fg = colors.keyword })
	hl("Type", { fg = colors.type })
	hl("StorageClass", { fg = colors.keyword })
	hl("Structure", { fg = colors.type })
	hl("Typedef", { fg = colors.type })
	hl("Special", { fg = colors.string_escape })
	hl("SpecialChar", { fg = colors.string_escape, bold = true })
	hl("Tag", { fg = colors.keyword })
	hl("Delimiter", { fg = colors.punctuation })
	hl("SpecialComment", { fg = colors.comment_alt, italic = true })
	hl("Debug", { fg = colors.error })
	hl("Underlined", { underline = true })
	hl("Ignore", { fg = colors.comment })
	hl("Error", { fg = colors.error, bold = true })

	-- Terminal Colors
	if not (config.disable and config.disable.terminal_colors) then
		vim.g.terminal_color_0 = colors.terminal_black
		vim.g.terminal_color_1 = colors.terminal_red
		vim.g.terminal_color_2 = colors.terminal_green
		vim.g.terminal_color_3 = colors.terminal_yellow
		vim.g.terminal_color_4 = colors.terminal_blue
		vim.g.terminal_color_5 = colors.terminal_magenta
		vim.g.terminal_color_6 = colors.terminal_cyan
		vim.g.terminal_color_7 = colors.terminal_white
		vim.g.terminal_color_8 = colors.terminal_bright_black
		vim.g.terminal_color_9 = colors.terminal_bright_red
		vim.g.terminal_color_10 = colors.terminal_bright_green
		vim.g.terminal_color_11 = colors.terminal_bright_yellow
		vim.g.terminal_color_12 = colors.terminal_bright_blue
		vim.g.terminal_color_13 = colors.terminal_bright_magenta
		vim.g.terminal_color_14 = colors.terminal_bright_cyan
		vim.g.terminal_color_15 = colors.terminal_bright_white
	end

	-- Plugin Integrations
	local plugins = config.plugins or {}

	local plugin_modules = {
		treesitter = "firesky.plugins.treesitter",
		lsp = "firesky.plugins.lsp",
		snacks = "firesky.plugins.snacks",
		telescope = "firesky.plugins.telescope",
		gitsigns = "firesky.plugins.gitsigns",
		blink = "firesky.plugins.blink",
		whichkey = "firesky.plugins.whichkey",
		trouble = "firesky.plugins.trouble",
		markdown = "firesky.plugins.markdown",
		mini = "firesky.plugins.mini",
	}

	for key, mod_name in pairs(plugin_modules) do
		if plugins[key] ~= false then
			local ok, mod = pcall(require, mod_name)
			if ok and mod.apply then
				mod.apply(colors, config)
			end
		end
	end

	-- User highlight overrides
	if config.highlights then
		for group, opts in pairs(config.highlights) do
			hl(group, opts)
		end
	end
end

return M
