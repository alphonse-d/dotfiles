local M = {}

function M.delete_current_file()
  local path = vim.fn.expand("%:p")

  if path == "" then
    vim.notify("No file to delete", vim.log.levels.WARN)
    return
  end

  local confirm = vim.fn.input(
    "Type DELETE to confirm deletion of:\n" .. path .. "\n> "
  )

  if confirm ~= "DELETE" then
    vim.notify("Canceled.", vim.log.levels.INFO)
    return
  end

  local ok, err = os.remove(path)
  if not ok then
    vim.notify("Delete failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.cmd("bd")
  vim.notify("Deleted: " .. path, vim.log.levels.INFO)
end

return M
