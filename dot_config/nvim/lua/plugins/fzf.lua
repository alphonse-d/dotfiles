return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  -- dependencies = { "echasnovski/mini.icons" },
  opts = {
        grep = {
                rg_opts = "--color=always --line-number --column --smart-case"
                },
        },
  config = function(_,opts)
    -- Check if ripgrep is installed
    if vim.fn.executable("rg") == 0 then
      vim.notify(
        "fzf-lua: ripgrep (rg) is not installed — live_grep will not work",
        vim.log.levels.ERROR
      )
    end
    -- being plugin stuff
    local fzf = require("fzf-lua")
    fzf.setup(opts)

    vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find Files (fzf-lua)" })
    vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live Grep (fzf-lua)" })
    vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Open Buffers (fzf-lua)" })
  end,
}
