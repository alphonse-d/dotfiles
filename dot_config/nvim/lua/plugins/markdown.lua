return{ 'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
			conceal = { enable = true },
			-- quotes, and settings to add space so wrapped lines aren't cut off
			quote = { repeat_linebreak = true },
			win_options = {
				showbreak = {
					default = '',
					rendered = '  ',
				},
				breakindent = {
					default = false,
					rendered = true,
				},
				breakindentopt = {
					default = '',
					rendered = '',
				},
		  },
			latex = {
				top_pad = 1, 
				bottom_pad = 1 },
			checkbox = {
				custom = {
					tracking = { raw = '[t]', rendered = '󱎄', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
					inprogress = { raw = '[i]', rendered = '󰔚', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
				},
			},
	},
}
