local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	-- Diagnostics
	hl("DiagnosticError", { fg = colors.error })
	hl("DiagnosticWarn", { fg = colors.warning })
	hl("DiagnosticInfo", { fg = colors.info })
	hl("DiagnosticHint", { fg = colors.hint })

	hl("DiagnosticVirtualTextError", { fg = colors.error, bg = colors.bg_dark })
	hl("DiagnosticVirtualTextWarn", { fg = colors.warning, bg = colors.bg_dark })
	hl("DiagnosticVirtualTextInfo", { fg = colors.info, bg = colors.bg_dark })
	hl("DiagnosticVirtualTextHint", { fg = colors.hint, bg = colors.bg_dark })

	hl("DiagnosticUnderlineError", { sp = colors.error, undercurl = true })
	hl("DiagnosticUnderlineWarn", { sp = colors.warning, undercurl = true })
	hl("DiagnosticUnderlineInfo", { sp = colors.info, undercurl = true })
	hl("DiagnosticUnderlineHint", { sp = colors.hint, undercurl = true })

	hl("DiagnosticFloatingError", { fg = colors.error })
	hl("DiagnosticFloatingWarn", { fg = colors.warning })
	hl("DiagnosticFloatingInfo", { fg = colors.info })
	hl("DiagnosticFloatingHint", { fg = colors.hint })

	hl("DiagnosticSignError", { fg = colors.error, bg = colors.bg })
	hl("DiagnosticSignWarn", { fg = colors.warning, bg = colors.bg })
	hl("DiagnosticSignInfo", { fg = colors.info, bg = colors.bg })
	hl("DiagnosticSignHint", { fg = colors.hint, bg = colors.bg })

	-- LSP References
	hl("LspReferenceText", { bg = colors.bg_highlight })
	hl("LspReferenceRead", { bg = colors.bg_highlight })
	hl("LspReferenceWrite", { bg = colors.bg_highlight, bold = true })

	-- Inlay Hints
	hl("LspInlayHint", { fg = colors.comment, bg = colors.bg_alt, italic = true })
	hl("LspCodeLens", { fg = colors.comment, italic = true })
	hl("LspSignatureActiveParameter", { fg = colors.bright_cyan, bold = true })
end

return M
