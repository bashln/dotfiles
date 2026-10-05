-- Firesky colorscheme entry point
-- Enables standard `colorscheme firesky` in Neovim

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "firesky"

local ok, firesky = pcall(require, "firesky")
if ok then
	firesky.load()
else
	local palette = require("firesky.palette").get()
	require("firesky.theme").apply({
		disable = {},
		colors = {},
		highlights = {},
		plugins = {},
	})
end
