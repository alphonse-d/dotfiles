-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
-- ###########################################################
-- Function to read environment variable from a file
local function read_env_var(file, var_name)
  local env_vars = io.open(file, "r")
  if not env_vars then
    print("Could not open environment file: " .. file)
    return nil
  end

  for line in env_vars:lines() do
    local key, value = line:match("^(%w+)=(.+)$")
    if key == var_name then
      env_vars:close()
      return value
    end
  end
  env_vars:close()
  return nil
end
-- ###########################################################
-- Function to search for a file recursively in a directory
local function search_zettelkasten_recursively(base_dir, filename)
  -- Escape the base directory and filename for safe shell execution
  local escaped_base_dir = vim.fn.shellescape(base_dir)
  local escaped_filename = vim.fn.shellescape(filename)
  -- Execute the find command
  local handle = io.popen(
    "find "
      .. escaped_base_dir
      .. " -type f \\( -name "
      .. escaped_filename
      .. " -o -name "
      .. escaped_filename
      .. ".md \\)"
  )
  if not handle then
    print("Error executing find command.")
    return nil
  end
  -- Read result
  local result = handle:read("*a")
  handle:close()
  if result ~= "" then
    return result:match("([^%s]+)\n")
  else
    return nil
  end
end
-- ###########################################################
-- Define Variables
local env_file = vim.fn.expand("~/bin/config.env") -- this will need to be changed, pending when I consolidate dotfiles
local base_dir = read_env_var(env_file, "ZETTELKASTEN")
if not base_dir then
  base_dir = nil -- If not found, use default behavior
  -- trailing "/" isn't needed for this script. Only the find command references it. Allows for matching when I am directly in the base_dir
  --else
  --base_dir = base_dir .. "/"
end
-- ###########################################################
-- Define a custom Function for gf to also search for filename.md extension.
local function gf_expansion()
  -- Get the filename under the cursor
  local filename = vim.fn.expand("<cfile>")
  -- Check if the exact filename exists
  if vim.fn.filereadable(filename) == 1 then
    vim.cmd("edit " .. filename)
    return
  else
    -- Check if the filename.md exists
    local md_filename = filename .. ".md"
    if vim.fn.filereadable(md_filename) == 1 then
      vim.cmd("edit " .. md_filename)
      return
    else
      -- Show error message if neither file is found
      print("File not found: " .. filename .. " or " .. md_filename)
    end
  end
  -- Get current working directory to check if I want to search full ZETTELKASTEN recursively
  local current_dir = vim.fn.getcwd()
  -- Check if base_dir is defined and if current directory is under base_dir
  if base_dir and vim.fn.matchstr(current_dir, base_dir) ~= "" then
    local recursive_filename = search_zettelkasten_recursively(base_dir, filename)
    print(recursive_filename)
    if recursive_filename ~= nil then
      vim.cmd("edit " .. recursive_filename)
      print("File was found recursively at: " .. recursive_filename)
    else
      print("File not found in Zettelkasten under: " .. base_dir .. "/")
    end
  end
end
-- Map the 'gf' command to the custom function
vim.keymap.set("n", "gf", gf_expansion, { noremap = true, silent = true })
-- ############################################################
