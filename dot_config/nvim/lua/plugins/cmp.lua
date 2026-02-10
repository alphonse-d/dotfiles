return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      completion = {
        autocomplete = false,
        completeopt = "menu,menuone,noinsert",
      },

      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                        cmp.select_next_item()
                else
                        fallback()
                end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                        cmp.select_prev_item()
                else
                        fallback()
                end
        end, { "i", "s" }),
          },

          sources = {
            { name = "nvim_lsp" },
            { name = "buffer" },
            { name = "path" },
          },
        })
end,
}
