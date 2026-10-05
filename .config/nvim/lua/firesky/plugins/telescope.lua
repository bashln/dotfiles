local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("TelescopeNormal", { fg = colors.fg, bg = colors.bg_dark })
	hl("TelescopeBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("TelescopeTitle", { fg = colors.bright_cyan, bg = colors.bg_dark, bold = true })

	hl("TelescopePromptNormal", { fg = colors.fg_bright, bg = colors.bg_alt })
	hl("TelescopePromptBorder", { fg = colors.accent, bg = colors.bg_alt })
	hl("TelescopePromptTitle", { fg = colors.darker_background, bg = colors.accent, bold = true })
	hl("TelescopePromptPrefix", { fg = colors.keyword, bold = true })

	hl("TelescopePreviewTitle", { fg = colors.darker_background, bg = colors.func, bold = true })
	hl("TelescopeResultsTitle", { fg = colors.darker_background, bg = colors.keyword, bold = true })

	hl("TelescopeSelection", { fg = colors.fg_bright, bg = colors.bg_highlight, bold = true })
	hl("TelescopeSelectionCaret", { fg = colors.bright_red, bold = true })
	hl("TelescopeMultiSelection", { fg = colors.bright_yellow, bg = colors.bg_highlight })
	hl("TelescopeMatching", { fg = colors.bright_yellow, bold = true })
end

return M
