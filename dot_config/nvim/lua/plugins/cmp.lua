return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup({
--      preselect = cmp.PreselectMode.None,
      snippet = {
        expand = function(args)
        require("luasnip").lsp_expand(args.body)
        end,
       },
      completion = {
        completeopt = "noselect,menu,menuone",
      },
      mapping = {
        --["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
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
            { name = "luasnip" },
          },
        })
    vim.api.nvim_create_user_command("CmpToggle", function()
      local cmp = require("cmp")
      local current = cmp.get_config().enabled
      cmp.setup.buffer({ enabled = not current })
    end, {})

end,
}
