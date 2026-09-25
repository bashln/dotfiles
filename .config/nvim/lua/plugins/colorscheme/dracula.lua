return {
  "Mofiqul/dracula.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- show the '~' characters after the end of buffers
    show_end_of_buffer = true,
    -- use transparent background
    transparent_bg = true,
    -- set custom lualine background color
    lualine_bg_color = "#44475a",
    -- italic styles
    italic_comment = true,
    -- overrides / custom colors
    overrides = {},
  },
  config = function(_, opts)
    local dracula = require("dracula")
    dracula.setup(opts)
  end,
}
