return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr, silent = true }

      -- Core, muscle-memory LSP navigation
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

      -- Optional actions (uncomment if/when you want them)
      -- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      -- vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

      -- Optional diagnostics navigation
      -- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      -- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end

  end,
}
