return {
  {
    name = "firesky",
    dir = vim.fn.stdpath("config"),
    lazy = true,
    priority = 1000,
    opts = {
      disable = {
        background = false, -- altere para true para transparência forçada
        italic_comments = false,
      },
    },
    config = function(_, opts)
      require("firesky").setup(opts)
    end,
  },
}
