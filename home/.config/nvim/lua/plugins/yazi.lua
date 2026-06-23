return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
  keys = {
    { "<leader>-,", mode = { "n", "v" }, "<cmd>Yazi<cr>", desc = "Open yazi at current file" },
    { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open yazi in nvim's working directory" },
    { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume last yazi session" },
  },
  opts = {
    open_for_directories = false,
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",
    log_level = vim.log.levels.OFF,
    open_file_function = function(chosen_file, config, state)
      vim.cmd("edit " .. vim.fn.fnameescape(chosen_file))
    end,
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
    clipboard_register = "*",
    integrations = {
      bufdelete_implementation = "bundled-snacks",
    },
  },
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
