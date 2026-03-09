-- lua/personal_custom/kanban_picker.lua
local M = {}

function M.open()
  local zk_root = vim.fn.expand("$ZK_NOTEBOOK_DIR")
  if zk_root == "" or zk_root == "$ZK_NOTEBOOK_DIR" then
    vim.notify("ZK_NOTEBOOK_DIR not set", vim.log.levels.ERROR)
    return
  end

  require("lazy").load({ plugins = { "fzf-lua" } })
  local fzf = require("fzf-lua")

  fzf.fzf_exec(
    string.format([[rg --files-with-matches --no-messages "kanban-plugin:\s*.+" %s]], vim.fn.shellescape(zk_root)),
    {
      prompt = "Kanban boards> ",
      previewer = "builtin",
      actions = {
        ["default"] = function(selected)
          local file = selected[1]
          if not file or file == "" then return end
          -- Trim whitespace
          file = vim.trim(file)
          vim.cmd("KanbanOpen " .. vim.fn.fnameescape(file))
        end,
      },
    }
  )
end

return M
