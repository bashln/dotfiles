local omarchy_theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(omarchy_theme) == 1 then
	local ok, theme_spec = pcall(dofile, omarchy_theme)
	if ok and type(theme_spec) == "table" then
		return theme_spec
	end
end

return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}
