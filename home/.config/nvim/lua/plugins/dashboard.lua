local bookmarks = {
  { icon = " ", file = "/home/bashln/leo/notes/", desc = "Notes" },
  { icon = " ", file = "/home/bashln/projects/", desc = "Projects" },
  { icon = "", file = "/home/bashln/dotfiles/", desc = "Dotfiles" },
  { icon = "󰒓 ", file = "/home/bashln/dotfiles/home/.config/nvim/", desc = "Nvim Config" },
}

local quotes = {
  { '"Simplicity is the ultimate sophistication."', "— Leonardo da Vinci" },
  { '"First, solve the problem. Then, write the code."', "— John Johnson" },
  { '"Code is like humor. When you have to explain it, it is bad."', "— Cory House" },
  { '"The best code is no code at all."', "— Jeff Atwood" },
  { '"Programs must be written for people to read."', "— Harold Abelson" },
  { '"Talk is cheap. Show me the code."', "— Linus Torvalds" },
  { '"Any fool can write code that a computer can understand."', "— Martin Fowler" },
}

local function daily_quote()
  return function()
    local day = math.floor(os.time() / 86400)
    local q = quotes[(day % #quotes) + 1]
    return {
      {
        text = {
          { "  ", hl = "SnacksDashboardIcon" },
          { q[1], hl = "SnacksDashboardFooter" },
        },
        align = "center",
        padding = { 2, 0 },
      },
      {
        text = { { q[2], hl = "SnacksDashboardSpecial" } },
        align = "center",
      },
    }
  end
end

local function bookmarks_section()
  return function()
    local items = {
      { text = { { "󰛖  Bookmarks", hl = "SnacksDashboardTitle" } }, padding = { 1, 0 } },
    }
    for _, b in ipairs(bookmarks) do
      items[#items + 1] = {
        icon = b.icon,
        desc = b.desc,
        action = ":e " .. vim.fn.fnameescape(vim.fn.expand(b.file)),
        key = string.char(96 + #items),
      }
    end
    return items
  end
end

return {
  { "nvimdev/dashboard-nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.width = 60
      opts.dashboard.pane_gap = 2
      opts.dashboard.preset = {
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗ ███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║ ████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║ ██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║ ██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝ ╚═╝     ╚═╝
        ]],
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        keys = {
          { icon = "󰈞 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "󰺾 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = "󰋚 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = "󰒓 ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })",
          },
          { icon = "󰁨 ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰿅 ", key = "q", desc = "Quit", action = ":qa" },
        },
      }
      opts.dashboard.sections = {
        { section = "header" },
        { section = "keys", gap = 0, padding = 0 },
        { gap = 1 },
        bookmarks_section(),
        { gap = 1 },
        { section = "startup", padding = { 1, 0 } },
        { pane = 2, section = "recent_files", limit = 8, indent = 0, padding = 0 },
        { pane = 2, section = "projects", limit = 5, indent = 0, padding = 0 },
        daily_quote(),
      }
    end,
  },
}
