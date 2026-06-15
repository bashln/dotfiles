return {
  "eldritch-theme/eldritch.nvim",
  lazy = false,
  enabled = false,
  priority = 1000,
  opts = {
    transparent = true,
    terminal_colors = true,
    styles = {
      comments = { italic = true },
      keywords = { italic = true },
      functions = {},
      variables = {},
      sidebars = "dark",
      floats = "dark",
    },
    sidebars = { "qf", "help" },
    hide_inactive_statusline = false,
    dim_inactive = false,
    lualine_bold = true,
    on_colors = function(colors) end,
    on_highlights = function(highlights, colors) end,
  },
}
