local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, config)
	local comment_opts = { fg = colors.comment }
	if not (config.disable and config.disable.italic_comments) then
		comment_opts.italic = true
	end

	-- Comments
	hl("@comment", comment_opts)
	hl("@comment.documentation", { fg = colors.comment_alt, italic = true })

	-- Keywords & Control flow
	hl("@keyword", { fg = colors.keyword })
	hl("@keyword.function", { fg = colors.keyword })
	hl("@keyword.return", { fg = colors.keyword, bold = true })
	hl("@keyword.operator", { fg = colors.operator })
	hl("@keyword.import", { fg = colors.keyword })
	hl("@conditional", { fg = colors.conditional, bold = true })
	hl("@repeat", { fg = colors.keyword, bold = true })
	hl("@exception", { fg = colors.error })

	-- Types & Identifiers
	hl("@type", { fg = colors.type })
	hl("@type.builtin", { fg = colors.bright_yellow })
	hl("@type.definition", { fg = colors.type })
	hl("@type.qualifier", { fg = colors.keyword })
	hl("@structure", { fg = colors.type })
	hl("@namespace", { fg = colors.type })

	-- Variables & Parameters
	hl("@variable", { fg = colors.variable })
	hl("@variable.builtin", { fg = colors.bright_yellow })
	hl("@variable.parameter", { fg = colors.fg_light })
	hl("@parameter", { fg = colors.fg_light })
	hl("@property", { fg = colors.property })
	hl("@field", { fg = colors.property })

	-- Functions & Methods
	hl("@function", { fg = colors.func })
	hl("@function.builtin", { fg = colors.func_builtin, bold = true })
	hl("@function.call", { fg = colors.func })
	hl("@function.macro", { fg = colors.func, bold = true })
	hl("@function.method", { fg = colors.func })
	hl("@function.method.call", { fg = colors.func })
	hl("@method", { fg = colors.func })
	hl("@method.call", { fg = colors.func })
	hl("@constructor", { fg = colors.type })

	-- Literals & Constants
	hl("@constant", { fg = colors.constant })
	hl("@constant.builtin", { fg = colors.bright_yellow, bold = true })
	hl("@constant.macro", { fg = colors.constant })
	hl("@string", { fg = colors.string })
	hl("@string.escape", { fg = colors.string_escape, bold = true })
	hl("@string.regex", { fg = colors.string_escape })
	hl("@string.special", { fg = colors.string_escape })
	hl("@character", { fg = colors.string })
	hl("@number", { fg = colors.number })
	hl("@number.float", { fg = colors.number })
	hl("@float", { fg = colors.number })
	hl("@boolean", { fg = colors.boolean, bold = true })

	-- Operators & Punctuation
	hl("@operator", { fg = colors.operator })
	hl("@punctuation.delimiter", { fg = colors.punctuation })
	hl("@punctuation.bracket", { fg = colors.punctuation })
	hl("@punctuation.special", { fg = colors.string_escape })

	-- Tags
	hl("@tag", { fg = colors.keyword })
	hl("@tag.attribute", { fg = colors.property })
	hl("@tag.delimiter", { fg = colors.punctuation })

	-- Modern Markup (@markup.*) and Legacy (@text.*)
	hl("@markup.heading", { fg = colors.keyword, bold = true })
	hl("@markup.strong", { bold = true })
	hl("@markup.italic", { italic = true })
	hl("@markup.strikethrough", { strikethrough = true })
	hl("@markup.underline", { underline = true })
	hl("@markup.link", { fg = colors.cyan, underline = true })
	hl("@markup.link.url", { fg = colors.bright_blue, underline = true })
	hl("@markup.raw", { fg = colors.string })
	hl("@markup.list", { fg = colors.keyword })

	hl("@text", { fg = colors.fg })
	hl("@text.strong", { bold = true })
	hl("@text.emphasis", { italic = true })
	hl("@text.underline", { underline = true })
	hl("@text.strike", { strikethrough = true })
	hl("@text.title", { fg = colors.keyword, bold = true })
	hl("@text.literal", { fg = colors.string })
	hl("@text.uri", { fg = colors.cyan, underline = true })
	hl("@text.todo", { fg = colors.bright_yellow, bold = true })
	hl("@text.warning", { fg = colors.warning, bold = true })
	hl("@text.danger", { fg = colors.error, bold = true })
end

return M
