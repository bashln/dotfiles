return {
  "stevearc/oil.nvim",
  ---@module "oil"
  ---@type oil.SetupOpts
  opts = function()
    local detail_view = false
    return {
      open_preview = {
        vertical = true,
        horizontal = false,
        split = "botright",
      },
      keymaps = {
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["q"] = { "actions.close", mode = "n" },
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["gd"] = {
          desc = "Toggle file detail view",
          callback = function()
            detail_view = not detail_view
            if detail_view then
              require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
            else
              require("oil").set_columns({ "icon" })
            end
          end,
        },
      },
      view_options = {
        show_hidden = true,
        is_hidden_file = function(name, _)
          return name:match("^%.") ~= nil
        end,
      },
    }
  end,
  dependencies = { { "nvim-mini/mini.icons", opts = {} }, { "refractalize/oil-git-status.nvim" } },
  lazy = false,
}
