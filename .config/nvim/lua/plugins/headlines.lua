-- https://github.com/lukas-reineke/headlines.nvim
-- Adds background banners/highlights to headlines (markdown, org, norg, ...).
-- Needs nvim-treesitter. `org` defaults exist; we only tweak them.
return {
  "lukas-reineke/headlines.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  event = "VeryLazy",
  config = function()
    require("headlines").setup({
      org = {
        headline_highlights = { "Headline1", "Headline2", "Headline3" },
        fat_headlines = false,
      },
    })

    -- Some colorschemes (e.g. cyberdream) don't define Headline1..3, which
    -- headlines uses for the org banners. Link missing groups to ColorColumn
    -- (the plugin's own default target) without overriding themes that define
    -- them. Re-run on ColorScheme since `hi clear` drops them.
    local function ensure_headline_groups()
      for _, grp in ipairs({ "Headline1", "Headline2", "Headline3" }) do
        if vim.fn.hlexists(grp) == 0 then
          vim.api.nvim_set_hl(0, grp, { link = "ColorColumn", default = true })
        end
      end
    end
    ensure_headline_groups()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = ensure_headline_groups })
  end,
}
