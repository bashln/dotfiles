-- Extend blink.cmp with the orgmode completion provider.
-- Adds TODO keywords, tags, properties, directives, links, dates in .org buffers.
-- Lazy deep-merges `opts`; `providers`/`per_filetype` are maps so no opts_extend needed.
return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      per_filetype = {
        org = { "orgmode" },
      },
      providers = {
        orgmode = {
          name = "Orgmode",
          module = "orgmode.org.autocompletion.blink",
          fallbacks = { "buffer" },
        },
      },
    },
  },
}
