-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
-- disable completion on markdown files by default
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    require("cmp").setup({ enabled = false })
  end,
})

vim.api.nvim_create_user_command("Date", function()
  local date = tostring(os.date("%c"))
  vim.api.nvim_put({ date }, "l", true, true)
end, {})
