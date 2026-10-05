local M = {}

local function hl(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.apply(colors, _)
	hl("GitSignsAdd", { fg = colors.git_add, bg = colors.bg })
	hl("GitSignsChange", { fg = colors.git_change, bg = colors.bg })
	hl("GitSignsDelete", { fg = colors.git_delete, bg = colors.bg })

	hl("GitSignsAddNr", { fg = colors.git_add })
	hl("GitSignsChangeNr", { fg = colors.git_change })
	hl("GitSignsDeleteNr", { fg = colors.git_delete })

	hl("GitSignsAddLn", { bg = colors.bg_highlight })
	hl("GitSignsChangeLn", { bg = colors.bg_highlight })
	hl("GitSignsDeleteLn", { bg = colors.bg_highlight })

	hl("GitSignsCurrentLineBlame", { fg = colors.comment, italic = true })
end

return M
