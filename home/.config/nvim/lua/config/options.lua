local opt = vim.opt
local g = vim.g

opt.scrolloff = 10
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.incsearch = true
opt.hlsearch = false
opt.updatetime = 150
opt.timeoutlen = 400

g.lazyvim_eslint_auto_format = true

if vim.env.HOME then
  local local_bin = vim.fn.expand("~/.local/bin")
  if local_bin and local_bin ~= "" then
    vim.env.PATH = local_bin .. ":" .. (vim.env.PATH or "")
  end
end
