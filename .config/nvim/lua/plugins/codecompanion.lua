return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "CodeCompanion",
    "CodeCompanionActions",
    "CodeCompanionChat",
    "CodeCompanionCLI",
    "CodeCompanionCodeReview",
  },
  opts = {
    opts = {
      language = "Portuguese",
    },
    interactions = {
      chat = {
        adapter = "opencode",
      },
      cli = {
        agent = "opencode",
        agents = {
          opencode = {
            cmd = "opencode",
            args = {},
            description = "OpenCode CLI",
            provider = "terminal",
          },
        },
      },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions" },
    { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat" },

    { "<leader>at", "<cmd>CodeCompanionCLI<cr>", mode = { "n", "v" }, desc = "AI terminal agent" },
    { "<leader>ar", "<cmd>CodeCompanionCodeReview<cr>", mode = "n", desc = "AI code review" },
  },
}
