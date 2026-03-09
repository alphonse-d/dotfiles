local M = {}

M.categories = { "Day", "Week", "Month", "Other" }

-- Extract the task chunk under the cursor. Returns chunk lines, chunk_start, chunk_end, all lines, or nil.
local function get_task_chunk()
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local cursor_pos = api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local total_lines = #lines

  if start_line >= total_lines then return nil end

  -- Move upwards to find bullet line or blank
  while start_line > 0 do
    local line_text = lines[start_line + 1]
    if line_text == "" or line_text:match("^%s*%-") then
      break
    end
    start_line = start_line - 1
  end
  if lines[start_line + 1] == "" and start_line < (total_lines - 1) then
    start_line = start_line + 1
  end

  local bullet_line = lines[start_line + 1]
  if not bullet_line:match("^%s*%-") then return nil end

  -- Identify chunk (bullet + following lines until blank or next bullet)
  local chunk_start = start_line
  local chunk_end = start_line
  while chunk_end + 1 < total_lines do
    local next_line = lines[chunk_end + 2]
    if next_line == "" or next_line:match("^%s*%-") then break end
    chunk_end = chunk_end + 1
  end

  local chunk = {}
  for i = chunk_start, chunk_end do
    table.insert(chunk, lines[i + 1])
  end

  return chunk, chunk_start, chunk_end, lines
end

function M.move_to_category(category)
  local heading = "## " .. category

  vim.cmd("mkview")
  local api = vim.api
  local buf = api.nvim_get_current_buf()

  local chunk, chunk_start, chunk_end, lines = get_task_chunk()
  if not chunk then
    vim.cmd("loadview")
    return
  end

  -- Check if task is already under this heading
  for i = chunk_start, 0, -1 do
    local line = lines[i + 1]
    if line:match("^## ") then
      if line == heading then
        vim.notify("Already in " .. category, vim.log.levels.WARN)
        vim.cmd("loadview")
        return
      end
      break
    end
  end

  -- Remove chunk from original spot
  for i = chunk_end, chunk_start, -1 do
    table.remove(lines, i + 1)
  end

  -- Find or create heading, insert chunk at top of section
  local heading_index
  for i, line in ipairs(lines) do
    if line == heading then
      heading_index = i
      break
    end
  end

  if heading_index then
    for _, cLine in ipairs(chunk) do
      table.insert(lines, heading_index + 1, cLine)
      heading_index = heading_index + 1
    end
    if lines[heading_index + 1] == "" then
      table.remove(lines, heading_index + 1)
    end
  else
    table.insert(lines, heading)
    for _, cLine in ipairs(chunk) do table.insert(lines, cLine) end
  end

  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.cmd("silent update")
  vim.cmd("loadview")
  vim.notify("Moved to " .. category, vim.log.levels.INFO)
end

function M.pick_category()
  vim.ui.select(M.categories, { prompt = "Move task to:" }, function(choice)
    if choice then
      M.move_to_category(choice)
    end
  end)
end

function M.toggle_task_and_move()
  -- Customize these:
  local label_done = "done:"
  local timestamp = os.date("%y%m%d-%H%M")
  local tasks_heading = "## Completed Tasks"

  vim.cmd("mkview")
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local cursor_pos = api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local total_lines = #lines

  if start_line >= total_lines then
    vim.cmd("loadview")
    return
  end

  -- Move upwards to find bullet line or blank
  while start_line > 0 do
    local line_text = lines[start_line + 1]
    if line_text == "" or line_text:match("^%s*%-") then
      break
    end
    start_line = start_line - 1
  end
  if lines[start_line + 1] == "" and start_line < (total_lines - 1) then
    start_line = start_line + 1
  end

  local bullet_line = lines[start_line + 1]
  if not bullet_line:match("^%s*%- %[[x ]%]") then
    vim.cmd("loadview")
    return
  end

  -- Identify chunk (bullet + following lines until blank or next bullet)
  local chunk_start = start_line
  local chunk_end = start_line
  while chunk_end + 1 < total_lines do
    local next_line = lines[chunk_end + 2]
    if next_line == "" or next_line:match("^%s*%-") then break end
    chunk_end = chunk_end + 1
  end

  local chunk = {}
  for i = chunk_start, chunk_end do
    table.insert(chunk, lines[i + 1])
  end

  -- Normalize old-style labels: [done:...] -> `done:...`, [untoggled] -> `untoggled`
  local has_done_index, has_untoggled_index
  for i, line in ipairs(chunk) do
    chunk[i] = line:gsub("%[done:([^%]]+)%]", "`" .. label_done .. "%1`")
    chunk[i] = chunk[i]:gsub("%[untoggled%]", "`untoggled`")
    if chunk[i]:match("`" .. label_done .. ".-`") then
      has_done_index = i
      break
    end
  end
  if not has_done_index then
    for i, line in ipairs(chunk) do
      if line:match("`untoggled`") then
        has_untoggled_index = i
        break
      end
    end
  end

  local function bulletToX(line) return line:gsub("^(%s*%- )%[%s*%]", "%1[x]") end
  local function bulletToBlank(line) return line:gsub("^(%s*%- )%[x%]", "%1[ ]") end
  local function insertLabelAfterBracket(line, label)
    local prefix = line:match("^(%s*%- %[[x ]%])")
    if not prefix then return line end
    local rest = line:sub(#prefix + 1)
    return prefix .. " " .. label .. rest
  end
  local function removeLabel(line)
    return line:gsub("^(%s*%- %[[x ]%])%s+`.-`", "%1")
  end

  local function updateBufferWithChunk(new_chunk)
    for idx = chunk_start, chunk_end do
      lines[idx + 1] = new_chunk[idx - chunk_start + 1]
    end
    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end

  if has_done_index then
    chunk[has_done_index] = removeLabel(chunk[has_done_index]):gsub("`" .. label_done .. ".-`", "`untoggled`")
    chunk[1] = bulletToBlank(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabelAfterBracket(chunk[1], "`untoggled`")
    updateBufferWithChunk(chunk)
    vim.notify("Untoggled", vim.log.levels.INFO)

  elseif has_untoggled_index then
    chunk[has_untoggled_index] = removeLabel(chunk[has_untoggled_index]):gsub("`untoggled`", "`" .. label_done .. " " .. timestamp .. "`")
    chunk[1] = bulletToX(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabelAfterBracket(chunk[1], "`" .. label_done .. " " .. timestamp .. "`")
    updateBufferWithChunk(chunk)
    vim.notify("Completed", vim.log.levels.INFO)

  else
    -- Mark + label
    chunk[1] = bulletToX(chunk[1])
    chunk[1] = insertLabelAfterBracket(chunk[1], "`" .. label_done .. " " .. timestamp .. "`")

    -- Remove chunk from original spot
    for i = chunk_end, chunk_start, -1 do
      table.remove(lines, i + 1)
    end

    -- Insert under heading (create if missing)
    local heading_index
    for i, line in ipairs(lines) do
      if line:match("^" .. tasks_heading) then
        heading_index = i
        break
      end
    end

    if heading_index then
      for _, cLine in ipairs(chunk) do
        table.insert(lines, heading_index + 1, cLine)
        heading_index = heading_index + 1
      end
      if lines[heading_index + 1] == "" then
        table.remove(lines, heading_index + 1)
      end
    else
      table.insert(lines, tasks_heading)
      for _, cLine in ipairs(chunk) do table.insert(lines, cLine) end
    end

    api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify("Completed", vim.log.levels.INFO)
  end

  vim.cmd("silent update")
  vim.cmd("loadview")
end

return M
