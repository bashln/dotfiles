local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("WhichKey", { fg = colors.keyword, bold = true })
	hl("WhichKeyGroup", { fg = colors.func })
	hl("WhichKeyDesc", { fg = colors.fg })
	hl("WhichKeySeparator", { fg = colors.comment })
	hl("WhichKeyNormal", { bg = colors.bg_dark })
	hl("WhichKeyBorder", { fg = colors.border, bg = colors.bg_dark })
	hl("WhichKeyValue", { fg = colors.comment })
end

return M
