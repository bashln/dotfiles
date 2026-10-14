return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>-",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at current file",
    },
    {
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi in working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume last yazi session",
    },
  },
  opts = {
    open_for_directories = false,
    open_multiple_tabs = true,
    change_neovim_cwd_on_close = true,
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
    keymaps = {
      show_help = "<f1>",
      open_file_in_vertical_split = "<c-v>",
      open_file_in_horizontal_split = "<c-x>",
      open_file_in_tab = "<c-t>",
      grep_in_directory = "<c-s>",
      replace_in_directory = "<c-g>",
      cycle_open_buffers = "<tab>",
      copy_relative_path_to_selected_files = "<c-y>",
      send_to_quickfix_list = "<c-q>",
      change_working_directory = "<c-\\>",
      open_and_pick_window = "<c-o>",
    },
    hooks = {
      yazi_opened = function(preselected_path, _yazi_buffer_id, _config)
        vim.cmd("silent! BufferLineTabRename yazi")
      end,
    },
    integrations = {
      grep_in_directory = function(directory)
        local telescope = require("telescope.builtin")
        telescope.live_grep({ cwd = directory })
      end,
      replace_in_directory = function(directory)
        -- grug-far.nvim integration (if installed)
        local ok, grug_far = pcall(require, "grug-far")
        if ok then
          grug_far.open({ prefills = { paths = directory } })
        end
      end,
      bufdelete_implementation = "bundled-snacks",
    },
    future_features = {
      use_cwd_file = true,
    },
  },
  init = function()
    -- PowerShell fix: https://github.com/mikavilpas/yazi.nvim/issues/675
    if vim.fn.has("win32") == 1 then
      vim.env.YAZI_CONFIG_HOME = vim.fn.expand("~/.config/yazi")
    end
  end,
}
