-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- PowerShell no Windows
if vim.fn.has("win32") == 1 then
  vim.o.shell = [[C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe]]
  vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
  vim.o.shellredir = '2>&1 | Out-File -Encoding utf8 %s'
  vim.o.shellpipe = '2>&1 | Out-File -Encoding utf8 %s'
  vim.o.shellxquote = ""
end
