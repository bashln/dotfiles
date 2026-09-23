local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

local spec = {
  -- add LazyVim and import its plugins
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },

  -- AI
  -- { import = "lazyvim.plugins.extras.ai.copilot" },

  -- coding
  { import = "lazyvim.plugins.extras.coding.yanky" },
  { import = "lazyvim.plugins.extras.coding.luasnip" },
  { import = "lazyvim.plugins.extras.coding.blink" },

  -- formatting
  { import = "lazyvim.plugins.extras.formatting.prettier" },

  -- lang
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.markdown" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
  { import = "lazyvim.plugins.extras.lang.terraform" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.typescript.biome" },
  -- { import = "lazyvim.plugins.extras.lang.react-native" },
  { import = "lazyvim.plugins.extras.lang.helm" },
  { import = "lazyvim.plugins.extras.lang.toml" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },

  -- editor
  { import = "lazyvim.plugins.extras.editor.harpoon2" },
  { import = "lazyvim.plugins.extras.editor.mini-diff" },
  { import = "lazyvim.plugins.extras.editor.snacks_picker" },
  { import = "lazyvim.plugins.extras.editor.snacks_explorer" },
  { import = "lazyvim.plugins.extras.editor.dial" },
  { import = "lazyvim.plugins.extras.editor.inc-rename" },

  -- util
  { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
  -- { import = "lazyvim.plugins.extras.util.project" }, -- disabled: replaced by workspaces.nvim
  { import = "lazyvim.plugins.extras.util.dot" },

  -- lsp
  -- { import = "lazyvim.plugins.extras.lsp.none-ls" },

  -- linting
  { import = "lazyvim.plugins.extras.linting.eslint" },

  -- test
  { import = "lazyvim.plugins.extras.test.core" },

  -- dap
  { import = "lazyvim.plugins.extras.dap.core" },

  -- ui
  -- { import = "lazyvim.plugins.extras.ui.mini-animate" },

  -- { import = "lazyvim.plugins.extras.lang.php" },
  -- { import = "lazyvim.plugins.extras.ai.copilot-chat" },

  -- import/override with your plugins
  { import = "plugins" },
  { import = "plugins/colorscheme" },
}

-- With the omarchy theme-hotreload disabled on win32, apply the first theme
-- configured natively in install.colorscheme instead of a LazyVim default.
if vim.fn.has("win32") == 1 then
  table.insert(spec, 1, { "LazyVim/LazyVim", opts = { colorscheme = "cursor-dark" } })
end

require("lazy").setup({
  spec = spec,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "cursor-dark", "tokyonight", "doom-one", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
