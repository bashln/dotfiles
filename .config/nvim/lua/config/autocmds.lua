-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Remove the default LazyVim wrap_spell augroup (which enables spell for markdown)
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Re-create wrap for all text filetypes (without spell)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wrap_text", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

-- Enable spell only for non-markdown text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("spell_text", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- Ignore stale swap files (crashed sessions) instead of hitting E325 ATTENTION.
-- 'o' = open read-only when a swap file exists: safest default, still surfaces
-- unsaved changes if another nvim instance really holds the file.
vim.api.nvim_create_autocmd("SwapExists", {
  group = vim.api.nvim_create_augroup("swap_exists", { clear = true }),
  callback = function()
    vim.v.swapchoice = "o"
  end,
})