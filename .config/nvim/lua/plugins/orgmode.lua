-- https://nvim-orgmode.github.io/
-- Orgmode clone for Neovim (0.11+). Parses .org files with tree-sitter.
--
-- Parser: the nvim-treesitter (main) registry does not ship the `org` parser,
-- so it is NOT added to `ensure_installed`. orgmode installs its own grammar on
-- first run; repair it with `:Org install_treesitter_grammar`.
--
-- Rendering: native conceal options + org-bullets for heading bullets.
-- `org_hide_leading_stars` is intentionally left off because org-bullets owns
-- the heading stars.
return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = { "org" },
  dependencies = {
    "nvim-orgmode/org-bullets.nvim",
    "danilshvalov/org-modern.nvim",
  },
  config = function()
    local Menu = require("org-modern.menu")

    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",

      -- Native rendering
      org_hide_emphasis_markers = true, -- conceal *bold* /italic/ ~code~ (conceallevel=2 in LazyVim)
      org_startup_indented = true, -- virtual indent for nested content
      org_indent_mode_turns_on_hiding_stars = false, -- let org-bullets render the stars
      org_highlight_latex_and_related = "entities", -- highlight $..$, $$..$$, \begin{}...
      org_startup_folded = "overview", -- open org files folded

      ui = {
        menu = {
          handler = function(data)
            Menu:new({
              window = {
                margin = { 1, 0, 1, 0 },
                padding = { 0, 1, 0, 1 },
                title_pos = "center",
                border = "single",
                zindex = 1000,
              },
              icons = { separator = "➜" },
            }):open(data)
          end,
        },
      },
    })

    -- Prettier bullets/icons for headings, lists and checkboxes
    require("org-bullets").setup({})

    -- Experimental LSP support
    vim.lsp.enable("org")
  end,
}
