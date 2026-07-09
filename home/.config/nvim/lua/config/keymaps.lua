local map = vim.keymap.set
local opts = { noremap = true, silent = true }

---@class Snacks
---@field picker table
---@field explorer fun()
---@field layout table

map("n", "-", "<cmd>Oil --float<CR>", { desc = "Oil: Parent (float)" })
map("n", "<leader>.", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })

vim.keymap.set("n", "<leader>e", function()
  local Snacks = require("snacks")
  local name = vim.api.nvim_buf_get_name(0)
  local dir = (name ~= "" and vim.fn.fnamemodify(name, ":p:h")) or vim.loop.cwd()
  Snacks.picker.explorer({
    cwd = dir,
    reveal = name ~= "" and name or nil,
    layout = { layout = { position = "left" } },
  })
end, { desc = "Explorer (aqui, direita)" })

map("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Diagnostics (float)" })

map("n", "sh", ":vsplit<CR>", opts)
map("n", "sv", ":split<CR>", opts)

map("v", "p", '"_dP', opts)
map("n", "p", '"_dP', opts)
map("n", "x", '"_x', opts)

map({ "n", "i" }, "<C-s>", function()
  vim.cmd("write")
end, { desc = "Salvar arquivo" })

map("n", "<C-h>", "<C-w>h", { desc = "Janela esquerda" })
map("n", "<C-j>", "<C-w>j", { desc = "Janela baixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Janela cima" })
map("n", "<C-l>", "<C-w>l", { desc = "Janela direita" })

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Mover linha ↓" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Mover linha ↑" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover seleção ↓" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover seleção ↑" })

map("n", "<leader>xx", function()
  require("trouble").toggle()
end, { desc = "Trouble" })

local function open_in_file_manager()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    print("No file is currently open")
    return
  end
  if vim.fn.has("macunix") == 1 then
    local command = "open -R " .. vim.fn.shellescape(file_path)
    vim.fn.system(command)
    print("Opened file in Finder: " .. file_path)
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    local command = "explorer /select," .. vim.fn.shellescape(file_path)
    vim.fn.system(command)
    print("Opened file in Explorer: " .. file_path)
  else
    vim.notify("Open in file manager not supported on this OS", vim.log.levels.WARN)
  end
end
vim.keymap.set({ "n", "v", "i" }, "<M-f>", open_in_file_manager, { desc = "Open current file in file explorer" })
vim.keymap.set("n", "<leader>fO", open_in_file_manager, { desc = "Open current file in file explorer" })

local ws_ok, workspaces = pcall(require, "workspaces")
if ws_ok then
  local wopts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>ww", function()
    workspaces.open()
  end, vim.tbl_extend("force", wopts, { desc = "Open workspace" }))
  vim.keymap.set("n", "<leader>wr", function()
    workspaces.rename()
  end, vim.tbl_extend("force", wopts, { desc = "Rename workspace" }))
  vim.keymap.set("n", "<leader>wa", function()
    workspaces.add()
  end, vim.tbl_extend("force", wopts, { desc = "Add workspace" }))
  vim.keymap.set("n", "<leader>wA", function()
    workspaces.add_dir()
  end, vim.tbl_extend("force", wopts, { desc = "Add workspace dir" }))
  vim.keymap.set("n", "<leader>wl", function()
    workspaces.list()
  end, vim.tbl_extend("force", wopts, { desc = "List workspaces" }))
  vim.keymap.set("n", "<leader>wd", function()
    workspaces.remove()
  end, vim.tbl_extend("force", wopts, { desc = "Remove workspace" }))
end
