return {
  "bashln/Doom-One.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = false, -- desabilita o fundo para transparência do terminal
    background = "dark", -- "dark", "darker", "light" (nil = usa vim.o.background)
    colors = {}, -- sobrescreve cores da paleta
    highlights = {}, -- sobrescreve grupos de destaque
    styles = {
      comments = { italic = true },
      conditionals = { italic = true },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    integrations = {
      all = true, -- habilita todas as integrações
      -- ou habilite individualmente:
      -- telescope = true,
      -- neotree = true,
      -- ...
    },
  },
}
