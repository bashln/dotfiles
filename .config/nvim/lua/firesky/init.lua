local M = {}

M.config = {
	disable = {
		background = false,      -- Set to true for transparent terminal background
		terminal_colors = false, -- Set to true to disable setting vim.g.terminal_color_*
		italic_comments = false, -- Set to true to disable italics in comments
	},
	colors = {},
	highlights = {},
	plugins = {
		treesitter = true,
		lsp = true,
		telescope = true,
		snacks = true,
		gitsigns = true,
		blink = true,
		whichkey = true,
		trouble = true,
		markdown = true,
		mini = true,
	},
}

function M.setup(user_config)
	if user_config then
		M.config = vim.tbl_deep_extend("force", M.config, user_config)
	end
end

function M.load()
	vim.o.background = "dark"

	vim.cmd("hi clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end

	vim.g.colors_name = "firesky"

	require("firesky.theme").apply(M.config)
end

function M.get_config()
	return M.config
end

return M
