local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("BlinkCmpMenu", { fg = colors.fg, bg = colors.bg_dark })
	hl("BlinkCmpMenuBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("BlinkCmpMenuSelection", { fg = colors.fg_bright, bg = colors.bg_highlight, bold = true })
	hl("BlinkCmpScrollBarThumb", { bg = colors.border })
	hl("BlinkCmpScrollBarGutter", { bg = colors.bg_dark })

	hl("BlinkCmpLabel", { fg = colors.fg })
	hl("BlinkCmpLabelDeprecated", { fg = colors.comment, strikethrough = true })
	hl("BlinkCmpLabelMatch", { fg = colors.bright_yellow, bold = true })
	hl("BlinkCmpLabelDetail", { fg = colors.comment })
	hl("BlinkCmpLabelDescription", { fg = colors.comment })

	hl("BlinkCmpKind", { fg = colors.func })
	hl("BlinkCmpKindFunction", { fg = colors.func })
	hl("BlinkCmpKindMethod", { fg = colors.func })
	hl("BlinkCmpKindConstructor", { fg = colors.type })
	hl("BlinkCmpKindVariable", { fg = colors.variable })
	hl("BlinkCmpKindClass", { fg = colors.type })
	hl("BlinkCmpKindInterface", { fg = colors.type })
	hl("BlinkCmpKindStruct", { fg = colors.type })
	hl("BlinkCmpKindProperty", { fg = colors.property })
	hl("BlinkCmpKindField", { fg = colors.property })
	hl("BlinkCmpKindKeyword", { fg = colors.keyword })
	hl("BlinkCmpKindConstant", { fg = colors.constant })
	hl("BlinkCmpKindSnippet", { fg = colors.orange })
	hl("BlinkCmpKindText", { fg = colors.fg })
	hl("BlinkCmpKindModule", { fg = colors.type })
	hl("BlinkCmpKindFile", { fg = colors.fg })
	hl("BlinkCmpKindFolder", { fg = colors.cyan })

	hl("BlinkCmpDoc", { fg = colors.fg, bg = colors.bg_dark })
	hl("BlinkCmpDocBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("BlinkCmpDocSeparator", { fg = colors.bg_light })
	hl("BlinkCmpDocCursorLine", { bg = colors.bg_highlight })

	hl("BlinkCmpSignatureHelp", { fg = colors.fg, bg = colors.bg_dark })
	hl("BlinkCmpSignatureHelpBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("BlinkCmpSignatureHelpActiveParameter", { fg = colors.bright_yellow, bold = true })
end

return M
