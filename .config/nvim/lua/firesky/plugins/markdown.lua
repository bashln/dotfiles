local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("markdownH1", { fg = colors.keyword, bold = true })
	hl("markdownH2", { fg = colors.func, bold = true })
	hl("markdownH3", { fg = colors.type, bold = true })
	hl("markdownH4", { fg = colors.bright_yellow, bold = true })
	hl("markdownH5", { fg = colors.bright_cyan, bold = true })
	hl("markdownH6", { fg = colors.comment, bold = true })

	hl("markdownHeadingDelimiter", { fg = colors.keyword, bold = true })
	hl("markdownCode", { fg = colors.string, bg = colors.bg_dark })
	hl("markdownCodeBlock", { fg = colors.fg, bg = colors.bg_dark })
	hl("markdownCodeDelimiter", { fg = colors.punctuation })
	hl("markdownBlockquote", { fg = colors.comment, italic = true })
	hl("markdownListMarker", { fg = colors.keyword })
	hl("markdownOrderedListMarker", { fg = colors.keyword })
	hl("markdownRule", { fg = colors.border })
	hl("markdownUrl", { fg = colors.cyan, underline = true })
	hl("markdownLinkText", { fg = colors.bright_cyan, underline = true })

	-- render-markdown.nvim support
	hl("RenderMarkdownH1", { fg = colors.keyword, bold = true })
	hl("RenderMarkdownH2", { fg = colors.func, bold = true })
	hl("RenderMarkdownH3", { fg = colors.type, bold = true })
	hl("RenderMarkdownH4", { fg = colors.bright_yellow, bold = true })
	hl("RenderMarkdownCode", { bg = colors.bg_dark })
	hl("RenderMarkdownCodeInline", { fg = colors.string, bg = colors.bg_dark })
	hl("RenderMarkdownBullet", { fg = colors.keyword })
	hl("RenderMarkdownTableHead", { fg = colors.bright_cyan, bold = true })
	hl("RenderMarkdownTableRow", { fg = colors.fg })
end

return M
