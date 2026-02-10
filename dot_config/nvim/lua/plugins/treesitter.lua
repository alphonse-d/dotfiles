return{
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
        ensure_installed = { 
          "lua", 
          "vim", 
          "markdown", 
          "markdown_inline", 
          "latex" 
          },
	sync_install = false,
	highlight = { enable = true },
	indent = { enable = true },
	},
}
