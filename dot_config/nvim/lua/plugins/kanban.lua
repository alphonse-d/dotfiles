return {
  "arakkkkk/kanban.nvim",
  -- Optional
--   dependencies = {
--     "nvim-telescope/telescope.nvim",
--   },
    keys = {
    {
      "<leader>kk",
      function()
        local zk_root = vim.fn.expand("$ZK_NOTEBOOK_DIR")
        if zk_root == "" then
          vim.notify("ZK_NOTEBOOK_DIR not set", vim.log.levels.ERROR)
          return
        end

        local board = zk_root .. "/kanban.md"
        vim.cmd("KanbanOpen " .. vim.fn.fnameescape(board))
      end,
      desc = "Open ZK Kanban",
    },
  },
  config = function()
    local zk_root = vim.fn.expand("$ZK_NOTEBOOK_DIR")

    require("kanban").setup({
      markdown = {
        description_folder = "./tasks/", -- Path to save the file corresponding to the task.
        list_head = "## ",
      },
    })
  end,
}
