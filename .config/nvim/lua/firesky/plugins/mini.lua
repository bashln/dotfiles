local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("MiniStatuslineDevinfo", { fg = colors.fg, bg = colors.bg_dark })
	hl("MiniStatuslineFileinfo", { fg = colors.fg, bg = colors.bg_dark })
	hl("MiniStatuslineFilename", { fg = colors.fg_bright, bg = colors.bg_alt })
	hl("MiniStatuslineInactive", { fg = colors.comment, bg = colors.bg_darker })
	hl("MiniStatuslineModeCommand", { fg = colors.darker_background, bg = colors.keyword, bold = true })
	hl("MiniStatuslineModeInsert", { fg = colors.darker_background, bg = colors.string, bold = true })
	hl("MiniStatuslineModeNormal", { fg = colors.darker_background, bg = colors.func, bold = true })
	hl("MiniStatuslineModeOther", { fg = colors.darker_background, bg = colors.type, bold = true })
	hl("MiniStatuslineModeReplace", { fg = colors.darker_background, bg = colors.error, bold = true })
	hl("MiniStatuslineModeVisual", { fg = colors.darker_background, bg = colors.accent, bold = true })

	hl("MiniDiffSignAdd", { fg = colors.git_add })
	hl("MiniDiffSignChange", { fg = colors.git_change })
	hl("MiniDiffSignDelete", { fg = colors.git_delete })

	hl("MiniHipatternsFixme", { fg = colors.darker_background, bg = colors.error, bold = true })
	hl("MiniHipatternsHack", { fg = colors.darker_background, bg = colors.warning, bold = true })
	hl("MiniHipatternsNote", { fg = colors.darker_background, bg = colors.info, bold = true })
	hl("MiniHipatternsTodo", { fg = colors.darker_background, bg = colors.bright_yellow, bold = true })
end

return M
