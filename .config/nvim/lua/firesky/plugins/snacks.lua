local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	-- Snacks.nvim Dashboard
	hl("SnacksDashboardHeader", { fg = colors.bright_red, bold = true })
	hl("SnacksDashboardTitle", { fg = colors.bright_cyan, bold = true })
	hl("SnacksDashboardDesc", { fg = colors.comment })
	hl("SnacksDashboardIcon", { fg = colors.func })
	hl("SnacksDashboardKey", { fg = colors.keyword, bold = true })
	hl("SnacksDashboardFooter", { fg = colors.comment, italic = true })
	hl("SnacksDashboardSpecial", { fg = colors.type })
	hl("SnacksDashboardDir", { fg = colors.comment })

	-- Snacks.nvim Notifier
	hl("SnacksNotifierInfo", { fg = colors.info, bg = colors.bg_dark })
	hl("SnacksNotifierWarn", { fg = colors.warning, bg = colors.bg_dark })
	hl("SnacksNotifierError", { fg = colors.error, bg = colors.bg_dark })
	hl("SnacksNotifierDebug", { fg = colors.hint, bg = colors.bg_dark })
	hl("SnacksNotifierTrace", { fg = colors.comment, bg = colors.bg_dark })

	hl("SnacksNotifierBorderInfo", { fg = colors.info, bg = colors.bg_dark })
	hl("SnacksNotifierBorderWarn", { fg = colors.warning, bg = colors.bg_dark })
	hl("SnacksNotifierBorderError", { fg = colors.error, bg = colors.bg_dark })
	hl("SnacksNotifierBorderDebug", { fg = colors.hint, bg = colors.bg_dark })
	hl("SnacksNotifierBorderTrace", { fg = colors.comment, bg = colors.bg_dark })

	hl("SnacksNotifierTitleInfo", { fg = colors.info, bold = true })
	hl("SnacksNotifierTitleWarn", { fg = colors.warning, bold = true })
	hl("SnacksNotifierTitleError", { fg = colors.error, bold = true })
	hl("SnacksNotifierTitleDebug", { fg = colors.hint, bold = true })
	hl("SnacksNotifierTitleTrace", { fg = colors.comment, bold = true })

	hl("SnacksNotifierIconInfo", { fg = colors.info })
	hl("SnacksNotifierIconWarn", { fg = colors.warning })
	hl("SnacksNotifierIconError", { fg = colors.error })
	hl("SnacksNotifierIconDebug", { fg = colors.hint })
	hl("SnacksNotifierIconTrace", { fg = colors.comment })

	-- Snacks.nvim Picker
	hl("SnacksPickerMatch", { fg = colors.bright_yellow, bold = true })
	hl("SnacksPickerPrompt", { fg = colors.keyword, bold = true })
	hl("SnacksPickerBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("SnacksPickerNormal", { fg = colors.fg, bg = colors.bg_dark })
	hl("SnacksPickerSelected", { fg = colors.fg_bright, bg = colors.bg_highlight, bold = true })
	hl("SnacksPickerDir", { fg = colors.comment })
	hl("SnacksPickerFile", { fg = colors.fg })
	hl("SnacksPickerRow", { fg = colors.comment })
	hl("SnacksPickerCol", { fg = colors.comment })

	-- Snacks.nvim Indent & Scroll
	hl("SnacksIndent", { fg = colors.bg_light })
	hl("SnacksIndentScope", { fg = colors.accent })
	hl("SnacksScroll", { fg = colors.border })
	hl("SnacksScrollThumb", { bg = colors.border })

	-- Snacks.nvim Debug / Log
	hl("SnacksDebug", { fg = colors.hint, italic = true })
	hl("SnacksLog", { fg = colors.comment, italic = true })
	hl("SnacksLogInfo", { fg = colors.info })
	hl("SnacksLogWarn", { fg = colors.warning })
	hl("SnacksLogError", { fg = colors.error })

	-- Snacks.nvim Toggle indicators
	hl("SnacksToggle", { fg = colors.operator })
	hl("SnacksToggleEnabled", { fg = colors.git_add, bold = true })
	hl("SnacksToggleDisabled", { fg = colors.comment })
end

return M
