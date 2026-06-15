-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local path_nav = require("config.path_navigation")

-- LuaLS: declare a global Snacks para evitar warning de undefined-global
---@class Snacks
---@field picker table
---@field explorer fun()
---@field layout table
Snacks = Snacks

-- ===== Arquivos / Gerenciadores =====
-- Oil (diretório pai em float)
map("n", "-", "<cmd>Oil --float<CR>", { desc = "Oil: Parent (float)" })
map("n", "<leader>.", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })

map("n", "<leader>fp", function()
  path_nav.browse_path(path_nav._last_dir or vim.uv.cwd())
end, { desc = "Browse path (Emacs-style)" })

map("n", "<leader>fd", function()
  local items = {}
  for c = string.byte("A"), string.byte("Z") do
    local drive = string.char(c) .. ":/"
    if vim.fn.isdirectory(drive) == 1 then
      table.insert(items, { text = drive, _path = drive })
    end
  end
  local Snacks = require("snacks")
  Snacks.picker({
    title = " Drives",
    items = items,
    format = function(item, _)
      return { { item.text } }
    end,
    confirm = function(picker, item)
      picker:close()
      path_nav.browse_path(item._path)
    end,
  })
end, { desc = "Pick drive / root" })

-- lua/config/keys-explorer-here.lua (ou dentro do seu snacks.lua)
vim.keymap.set("n", "<leader>e", function()
  local Snacks = require("snacks")
  local name = vim.api.nvim_buf_get_name(0)
  local dir = (name ~= "" and vim.fn.fnamemodify(name, ":p:h")) or vim.loop.cwd()

  -- Abre na direita, com cwd = diretório do buffer atual, revelando o arquivo
  Snacks.picker.explorer({
    cwd = dir,
    reveal = name ~= "" and name or nil,
    layout = { layout = { position = "left" } },
  })
end, { desc = "Explorer (aqui, direita)" })

-- ===== Diagnóstico =====
map("n", "gl", function()
  vim.diagnostic.open_float()
end, { desc = "Diagnostics (float)" })

-- ===== Splits =====
-- 'sh' → vertical split (vsplit) | 'sv' → horizontal split (split)
map("n", "sh", ":vsplit<CR>", opts)
map("n", "sv", ":split<CR>", opts)

-- ===== Indentação visual =====
map("v", "<", "<gv", { desc = "Indent -" })
map("v", ">", ">gv", { desc = "Indent +" })

-- ===== Paste/Del “limpos” =====
map("v", "p", '"_dP', opts) -- cola sem sobrescrever registro
map("n", "p", '"_dP', opts) -- cola sem sobrescrever registro
map("n", "x", '"_x', opts) -- deleta char sem ir p/ registro

-- ===== Salvar / Sair =====
map({ "n", "i" }, "<C-s>", function()
  vim.cmd("write")
end, { desc = "Salvar arquivo" })
map("n", "<leader>qq", ":qa<CR>", { desc = "Sair do Neovim" })

-- ===== Navegação de janelas =====
map("n", "<C-h>", "<C-w>h", { desc = "Janela esquerda" })
map("n", "<C-j>", "<C-w>j", { desc = "Janela baixo" })
map("n", "<C-k>", "<C-w>k", { desc = "Janela cima" })
map("n", "<C-l>", "<C-w>l", { desc = "Janela direita" })

-- ===== Mover linhas =====
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Mover linha ↓" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Mover linha ↑" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover seleção ↓" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover seleção ↑" })

-- ===== Trouble (diagnósticos) =====
-- LazyVim já integra bem; este toggle é útil:
map("n", "<leader>xx", function()
  require("trouble").toggle()
end, { desc = "Trouble" })

-- Markdown folding configuration (foldexpr + autocmds)
require("config.markdown-folding")

-- Function to open current file in Finder or ForkLift
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

vim.keymap.set({ "n", "v", "i" }, "<M-f>", open_in_file_manager, { desc = "[P]Open current file in file explorer" })
vim.keymap.set("n", "<leader>fO", open_in_file_manager, { desc = "[P]Open current file in file explorer" })

-- ===== Workspaces keymaps =====
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
