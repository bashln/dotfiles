-- https://nvim-orgmode.github.io/
-- Orgmode clone for Neovim (0.11+). Parses .org files with tree-sitter.
--
-- Parser: the nvim-treesitter (main) registry does not ship the `org` parser,
-- so it is NOT added to `ensure_installed`. orgmode installs its own grammar on
-- first run; repair it with `:Org install_treesitter_grammar`.
return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = { "org" },
  config = function()
    require("orgmode").setup({
      org_agenda_files = "~/orgfiles/**/*",
      org_default_notes_file = "~/orgfiles/refile.org",
    })

    -- Experimental LSP support
    vim.lsp.enable("org")
  end,
}
