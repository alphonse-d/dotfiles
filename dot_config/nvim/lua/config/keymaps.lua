-- Buffer switching
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', { noremap = true, silent = true })

-- DeleteFile function
vim.api.nvim_create_user_command("DeleteFile", function()
  require("user.deletefile").delete_current_file()
end, { desc = "Delete current file with confirmation" })

vim.keymap.set("n", "<leader>D", function()
  require("user.deletefile").delete_current_file()
end, { desc = "Delete current file" })

-- Todo task complete chunk
vim.keymap.set("n", "<leader>tc", function()
        require("user.todo").toggle_task_and_move()
end, { desc = "Toggle task + move to Completed Tasks" })

-- Todo task category movement
vim.keymap.set("n", "<leader>td", function()
  require("user.todo").move_to_category("Day")
end, { desc = "Move task to Day" })

vim.keymap.set("n", "<leader>tw", function()
  require("user.todo").move_to_category("Week")
end, { desc = "Move task to Week" })

vim.keymap.set("n", "<leader>tm", function()
  require("user.todo").move_to_category("Month")
end, { desc = "Move task to Month" })

vim.keymap.set("n", "<leader>to", function()
  require("user.todo").move_to_category("Other")
end, { desc = "Move task to Other" })

vim.keymap.set("n", "<leader>tp", function()
  require("user.todo").pick_category()
end, { desc = "Pick category for task" })

