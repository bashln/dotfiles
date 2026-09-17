-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- PowerShell Core no Windows
if vim.fn.has("win32") == 1 then
  vim.o.shell = "pwsh"
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.o.shellredir = '2>&1 | Out-File -Encoding utf8 %s'
  vim.o.shellpipe = '2>&1 | Out-File -Encoding utf8 %s'
  vim.o.shellxquote = ""
end
