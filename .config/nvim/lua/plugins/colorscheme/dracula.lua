return {
  "Mofiqul/dracula.nvim",
  lazy = true,
  priority = 1000,
  opts = {
    show_end_of_buffer = true,
    transparent_bg = false,
    lualine_bg_color = "#44475a",
    italic_comment = true,
    overrides = {
      Normal = { bg = "#282a36" },
      NormalFloat = { bg = "#282a36" },
      SignColumn = { bg = "#282a36" },
      LineNr = { bg = "#282a36" },
      CursorLineNr = { bg = "#282a36" },
    },
  },
  config = function(_, opts)
    local dracula = require("dracula")
    dracula.setup(opts)
  end,
}
