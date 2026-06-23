-- Buffer-local fold keymaps for markdown
-- Preserves native z-fold motions (zj, zk, zl, z;, zi)
-- Fold logic (foldexpr, autocmds) lives in config/markdown-folding.lua
vim.opt_local.spell = false

local map = vim.keymap.set
local opts = { buffer = true, silent = true }

map("n", "<leader>m1", function()
  vim.opt_local.foldlevel = 1
end, vim.tbl_extend("force", opts, { desc = "Fold level 1" }))
map("n", "<leader>m2", function()
  vim.opt_local.foldlevel = 2
end, vim.tbl_extend("force", opts, { desc = "Fold level 2" }))
map("n", "<leader>m3", function()
  vim.opt_local.foldlevel = 3
end, vim.tbl_extend("force", opts, { desc = "Fold level 3" }))
map("n", "<leader>m4", function()
  vim.opt_local.foldlevel = 4
end, vim.tbl_extend("force", opts, { desc = "Fold level 4" }))

map("n", "<leader>mu", function()
  vim.opt_local.foldlevel = 99
end, vim.tbl_extend("force", opts, { desc = "Unfold all" }))
map("n", "<leader>mc", function()
  vim.opt_local.foldlevel = 0
end, vim.tbl_extend("force", opts, { desc = "Fold all (close)" }))
