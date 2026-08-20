return {
  "bashln/matteblack",
  lazy = false,
  priority = 1000,
  init = function(plugin)
    vim.opt.rtp:prepend(plugin.dir .. "/nvim")
  end,
}
