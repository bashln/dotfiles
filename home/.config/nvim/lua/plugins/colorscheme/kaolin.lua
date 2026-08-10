return {
  -- Local dev checkout while improving the theme
  dir = "C:/Users/itinerario/Documents/leo/development/projects/neovim-kaolin-themes",
  lazy = false,
  priority = 1000,
  init = function()
    vim.g.kaolin_opts = {
      transparent_background = true,
      variant = "auto",
      dim_inactive = true,
      styles = {
        bold = true,
        italic = true,
        italic_comments = true,
      },
    }
  end,
}
