return {
  "zk-org/zk-nvim",
  config = function()
    local zk = require("zk")
    local zk_util = require("zk.util")

    zk.setup({
      picker = "fzf_lua",
      lsp = {
        config = {
          cmd = { "zk", "lsp" },
          name = "zk",
          on_attach = function(client, bufnr)
            local path = vim.api.nvim_buf_get_name(bufnr)
            local zk_root = zk_util.notebook_root(path)

            -- If NOT a zk notebook file, stop here (no maps, no commands, no autocmds)
            if not zk_root then
              return
            end

            -- Notebook-only settings
            -- spell is window-local
            vim.api.nvim_set_option_value("spell", true, { win = 0 })
            -- spelllang is buffer-local (in your build)
            vim.api.nvim_set_option_value("spelllang", "en_us", { buf = bufnr })


            local function map(mode, lhs, rhs)
              vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
            end

            -- ZK keymaps (buffer-local: only in notebook buffers)
            map("n", "<leader>zc", "<cmd>ZkCd<CR>")
            map("n", "<leader>zn", "<cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>")
            map("v", "<leader>zn", ":'<,'>ZkNewFromTitleSelection<CR>")
            map("n", "<leader>zo", "<cmd>ZkNotes { sort = { 'modified' } }<CR>")
            map("v", "<leader>zo", ":'<,'>ZkMatch { sort = { 'modified' } }<CR>")
            map("n", "<leader>zm", "<cmd>FzfLua live_grep<CR>")
            map("n", "<leader>zB", "<cmd>ZkBuffers<CR>")
            map("n", "<leader>zl", "<cmd>ZkLinks<CR>")
            map("n", "<leader>zb", "<cmd>ZkBacklinks<CR>")
            map("v", "<leader>zi", ":'<,'>ZkInsertLinkAtSelection {matchSelected = true}<CR>")
            map("n", "<leader>zi", "<cmd>ZkInsertLink { sort = { 'modified' } }<CR>")
            map("n", "<leader>zt", "<cmd>ZkTags<CR>")
            map("n", "<leader>zy", "<cmd>ZkInsertYamlHeader<CR>")

            -- ZkRename (buffer-local command)
            vim.api.nvim_buf_create_user_command(bufnr, "ZkRename", function()
              if vim.bo[bufnr].modified then
                vim.notify("Save the buffer before renaming.", vim.log.levels.WARN, { title = "ZkRename" })
                return
              end

              local file = vim.api.nvim_buf_get_name(bufnr)
              if file == "" then
                vim.notify("Buffer has no file path.", vim.log.levels.WARN, { title = "ZkRename" })
                return
              end

              local dir = vim.fn.fnamemodify(file, ":h")
              local filename = vim.fn.fnamemodify(file, ":t")

              -- Enforce: directly inside ZK_NOTEBOOK_DIR
              local notebook_dir = vim.fn.expand(vim.fn.getenv("ZK_NOTEBOOK_DIR") or "")
              if notebook_dir ~= "" then
                notebook_dir = vim.fn.fnamemodify(notebook_dir, ":p"):gsub("/$", "")
                local dir_p = vim.fn.fnamemodify(dir, ":p"):gsub("/$", "")
                if dir_p ~= notebook_dir then
                  vim.notify(
                    filename .. " is not directly inside " .. notebook_dir .. ". Filename not changed.",
                    vim.log.levels.INFO,
                    { title = "ZkRename" }
                  )
                  return
                end
              end

              -- Require hex prefix: <hex>-something.md
              local hex_prefix = filename:match("^(%x+)%-.+%.md$")
              if not hex_prefix then
                vim.notify("Filename must start with a hex prefix like abcd-title.md", vim.log.levels.WARN, { title = "ZkRename" })
                return
              end

              -- YAML title on line 2: title: My Note
              local title_line = vim.fn.getbufline(bufnr, 2)[1] or ""
              local title = title_line:match("^title:%s*[\"']?(.-)[\"']?$")
              if not title or title == "" then
                vim.notify("Second line must be `title: My Note`. Filename not changed.", vim.log.levels.INFO, { title = "ZkRename" })
                return
              end

              local slug = title
                :lower()
                :gsub("[^a-z0-9]+", "-")
                :gsub("%-+", "-")
                :gsub("^%-", "")
                :gsub("%-$", "")

              local new_filename = hex_prefix .. "-" .. slug .. ".md"
              local new_path = dir .. "/" .. new_filename

              if file == new_path then
                vim.notify("Title did not change. Filename did not change.", vim.log.levels.INFO, { title = "ZkRename" })
                return
              end

              local ok, err = os.rename(file, new_path)
              if not ok then
                vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR, { title = "ZkRename" })
                return
              end

              vim.cmd("edit " .. vim.fn.fnameescape(new_path))
              pcall(vim.cmd, "bwipeout " .. vim.fn.fnameescape(file))
              vim.notify("Renamed to: " .. new_filename, vim.log.levels.INFO, { title = "ZkRename" })
            end, { desc = "Rename current file to match YAML frontmatter title" })

            -- Auto-run ZkRename on save (notebook only)
            local grp = vim.api.nvim_create_augroup("ZkRename_" .. bufnr, { clear = true })
            vim.api.nvim_create_autocmd("BufWritePost", {
              group = grp,
              buffer = bufnr,
              callback = function()
                local file = vim.api.nvim_buf_get_name(bufnr)
                if zk_util.notebook_root(file) then
                  vim.schedule(function()
                    pcall(vim.cmd, "ZkRename")
                  end)
                end
              end,
            })
          end,
        },

        -- Let zk-nvim attach to markdown, but we gate behavior by notebook_root in on_attach
        auto_attach = {
          enabled = true,
          filetypes = { "markdown" },
        },
      },
    })

    -- YAML header insert command (global is fine)
    vim.api.nvim_create_user_command("ZkInsertYamlHeader", function()
      local bufnr = 0
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

      local title
      for _, line in ipairs(lines) do
        title = line:match("^#%s+(.+)")
        if title then break end
      end

      local filename = vim.fn.expand("%:t")
      local hex_id = filename:match("^(%x%x%x%x)%-")

      title = title or ""
      hex_id = hex_id or ""

      local template = {
        "---",
        "title: " .. title,
        "id: " .. hex_id,
        "aliases: ",
        "keywords: ",
        "---",
        "",
      }

      vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, template)
    end, { desc = "Insert YAML frontmatter at top of file" })
  end,
}

