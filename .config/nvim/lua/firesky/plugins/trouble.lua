local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("TroubleNormal", { fg = colors.fg, bg = colors.bg_dark })
	hl("TroubleCount", { fg = colors.keyword, bold = true })
	hl("TroubleText", { fg = colors.fg })
	hl("TroubleSource", { fg = colors.comment })
	hl("TroubleLocation", { fg = colors.comment })
	hl("TroubleFoldIcon", { fg = colors.func })
	hl("TroubleIndent", { fg = colors.bg_light })
end

return M
