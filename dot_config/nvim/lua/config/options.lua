-- turn off mouse
vim.o.mouse = ""

-- set tab/indent to 2 characters
--vim.o.shiftwidth = 2
--vim.o.tabstop = 2
vim.o.expandtab = true

-- visually
vim.o.linebreak = true -- breaks lines at full words
vim.o.number = true

-- spell, ignore capitalization errors
vim.opt.spellcapcheck = ""

-- Extra Commands
vim.api.nvim_create_user_command("DeleteFile", function()
  local path = vim.fn.expand("%:p")
  -- local confirm = vim.fn.confirm("Delete file?\n" .. path, "Yes\n&No", 2) -- This causes delete with one keystroke "y". Would like better confirmation
	local confirm = vim.fn.input("Type DELETE to confirm deletion of:\n" .. path .. "\n> ")
  if confirm == "DELETE" then
    os.remove(path)
    vim.cmd("bd")
    print("\nDeleted: " .. path)
  else
    print("\nCanceled.")
  end
end, { desc = "Delete current file with confirmation" })

-- Buffer switching
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', { noremap = true, silent = true })

-- Close all buffers and reopen active one
        -- Define the BufOnly command
vim.api.nvim_create_user_command('BufOnly', function()
  vim.cmd('%bd | e# | bd#')
end, {})
        -- Keymap to close all other buffers
vim.keymap.set('n', '<leader>bo', ':BufOnly<CR>', { noremap = true, silent = true })
