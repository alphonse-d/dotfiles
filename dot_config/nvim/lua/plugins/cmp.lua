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
--      preselect = cmp.PreselectMode.None,

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
          },
        })
    vim.api.nvim_create_user_command("CmpToggle", function()
      local cmp = require("cmp")
      local current = cmp.get_config().enabled
      cmp.setup.buffer({ enabled = not current })
    end, {})

end,
}
