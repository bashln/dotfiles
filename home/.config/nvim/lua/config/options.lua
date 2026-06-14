-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g

-- Líder
g.mapleader = " "

-- ========== UI / Edição ==========
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 10 -- manter “folga” vertical
opt.sidescrolloff = 8

-- Mostrar caracteres invisíveis (útil p/ revisão)
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ========== Indentação ==========
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- ========== Busca ==========
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = false

-- ========== Desempenho ==========
opt.updatetime = 150
opt.timeoutlen = 400

-- ========== Clipboard ==========
opt.clipboard = "unnamedplus"

-- ========== Outros ==========
opt.splitbelow = true
opt.splitright = true
opt.conceallevel = 2

-- ===== LazyVim specifics =====
-- ESLint autoformat (se estiver usando extras linting.eslint)
g.lazyvim_eslint_auto_format = true
-- Toggle global de autoformat no save (do LazyVim); deixe comentado se não quiser mexer.
g.autoformat = true

-- Ensure Neovim sees user-installed binaries (prettier/biome) in ~/.local/bin
-- This helps conform locate the executables when running formatters.
if vim.env.HOME then
  local local_bin = vim.fn.expand("~/.local/bin")
  if local_bin and local_bin ~= "" then
    vim.env.PATH = local_bin .. ":" .. (vim.env.PATH or "")
  end
end
