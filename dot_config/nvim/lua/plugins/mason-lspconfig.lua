return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
	config = function()
		require("mason-lspconfig").setup({
                        ensure_installed = {
                                "lua_ls",       --Lua
                                "pyright",      --Python
                                "yamlls",       --YAML
                                "terraformls",  --Terraform
                                "jsonls",       --JSON
                                "bashls",       --bash language server
                                "zk",           --Zettelkasten
                        }
		}) end,
}
