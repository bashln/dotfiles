-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- Persist recent files (oldfiles), undo, and shada across sessions
vim.opt.shada = "!,'100,<50,s10,h"

if vim.fn.has("win32") == 1 then
  -- Windows: shada path fix — stdpath("data") may diverge from actual AppData location
  vim.opt.shadafile = vim.fn.stdpath("data") .. "/shada/main.shada"
  vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
else
  vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
end

-- Persistent undo
vim.opt.undofile = true

-- PowerShell no Windows
if vim.fn.has("win32") == 1 then
  vim.o.shellslash = true
  vim.o.shell = [[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe]]
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.o.shellredir = '2>&1 | Out-File -Encoding utf8 %s'
  vim.o.shellpipe = '2>&1 | Out-File -Encoding utf8 %s'
  vim.o.shellxquote = ""
end
