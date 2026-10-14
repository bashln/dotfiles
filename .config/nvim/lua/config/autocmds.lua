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

-- Disable snacks picker backdrop (transparent background)
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("snacks_no_backdrop", { clear = true }),
  pattern = "SnacksPickerOpened",
  callback = function()
    local snacks = require("snacks")
    if snacks.picker then
      snacks.picker.setup({ backdrop = false })
    end
  end,
})

-- Ensure opaque background on Windows
if vim.fn.has("win32") == 1 then
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("win32_opaque_bg", { clear = true }),
    pattern = "*",
    callback = function()
      vim.api.nvim_set_hl(0, "Normal", { bg = "#282a36" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282a36" })
      vim.o.winblend = 0
    end,
  })
end