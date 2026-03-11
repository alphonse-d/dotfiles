return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  config = function()
    local ls = require("luasnip")

    ls.config.setup({
      enable_autosnippets = true,
      updateevents = "TextChanged,TextChangedI",
    })

    require("luasnip.loaders.from_lua").load({
      paths = vim.fn.stdpath("config") .. "/lua/snippets",
    })
  end,
}
