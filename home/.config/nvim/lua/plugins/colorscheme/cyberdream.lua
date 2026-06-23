return {
  "scottmckendry/cyberdream.nvim",
  lazy = true,
  cmd = { "CyberdreamLoad" },
  opts = {
    transparent = false,
    italic_comments = true,
    terminal_colors = true,
  },
  config = function(_, opts)
    require("cyberdream").setup(opts)
    vim.api.nvim_create_user_command("CyberdreamLoad", function()
      vim.cmd.colorscheme("cyberdream")
    end, { desc = "Load cyberdream colorscheme" })
  end,
}
