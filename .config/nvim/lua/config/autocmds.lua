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

-- Stale swap files (crashed sessions), without hitting the E325 ATTENTION
-- prompt: pick the action from the swap age instead of always choosing "o".
-- "o" opens the buffer read-only, so every later ":w" asked
-- "'readonly' option is set for ...". Do you wish to write anyway?
-- A swap older than the file on disk holds nothing the file does not already
-- have -> "d" (drop it, writable buffer). A swap at least as new as the file
-- may belong to a live nvim (after ":w" Vim keeps the swap mtime in sync with
-- the file, so a live session is never seen as older) -> "o", read-only, which
-- keeps that session's data. On Windows a live swap is also locked, so a
-- wrong "d" fails instead of deleting it; on Linux (no locking) the age check
-- is the only guard.
vim.api.nvim_create_autocmd("SwapExists", {
  group = vim.api.nvim_create_augroup("swap_exists", { clear = true }),
  callback = function()
    local swap = vim.v.swapname
    local file = vim.fn.expand("<afile>")
    local stale = swap ~= "" and vim.fn.getftime(swap) < vim.fn.getftime(file)
    vim.v.swapchoice = stale and "d" or "o"
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
      -- Force an opaque background using the active theme's own Normal color,
      -- so this does not pin a color that belongs to a different colorscheme.
      local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
      if bg then
        vim.api.nvim_set_hl(0, "Normal", { bg = bg })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = bg })
      end
      vim.o.winblend = 0
    end,
  })
end