Core = {}

Core.setOptions = function(options)
    for type, opts in pairs(options) do
        for k, v in pairs(opts) do
            vim[type][k] = v;
        end
    end
end

Core.setKeyMaps = function(keymaps)
    for _, maps in pairs(keymaps) do
        vim.keymap.set(maps[1], maps[2], maps[3], maps[4] or {})
    end
end

Core.setCommentStrings = function(commentstrings)
    for _, opts in pairs(commentstrings) do
        vim.api.nvim_create_autocmd("FileType", {
            pattern = opts.pattern,
            callback = function() vim.bo.commentstring = opts.cs end
        })
    end
end

Core.createAutoCommand = function(event, pattern, callback)
    vim.api.nvim_create_autocmd(event, { pattern = pattern, callback = callback })
end

Core.hlkind = { ui = "gui", fg = "guifg", bg = "guibg" }
Core.setHighlights = function(highlights)
    for group, args in pairs(highlights) do
        local command = string.format("highlight %s ", group)
        for arg, value in pairs(args) do
            command = command .. Core.hlkind[arg] .. "=" .. value .. " "
        end
        vim.api.nvim_command(command)
    end
end

Core.linkHighlights = function(highlights)
    for group, link in pairs(highlights) do
        local command = string.format("highlight! link %s %s", group, link)
        vim.api.nvim_command(command)
    end
end

Core.clearHighlights = function(highlights)
    for _, group in pairs(highlights) do
        vim.api.nvim_command("highlight clear " .. group)
    end
end

Core.wsl = function()
    if vim.fn.has("unix") then
        local version = vim.fn.readfile("/proc/version")
        for _, v in ipairs(version) do
            if vim.fn.match(v, "WSL") >= 0 then
                return true
            end
        end
    end
    return false
end

Core.lineComment = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" or mode == "i" then
        local line = vim.api.nvim_get_current_line()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        if not line:find("%S") then
            local cs = vim.bo.commentstring
            if cs == nil or cs == '' then
                return Core.warn("Option 'commentstring' is empty.")
            end
            local cursor_position = { row, col + cs:find("%%s") - 1 }
            local commentline = string.rep(" ", col) .. cs:gsub("%%s", "")
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, { commentline })
            vim.api.nvim_win_set_cursor(0, cursor_position)

            if mode == "n" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", false)
            end
        else
            require("vim._comment").toggle_lines(row, row)
        end
    else
        local srow = math.min(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
        local erow = math.max(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
        require("vim._comment").toggle_lines(srow, erow)
    end
end

Core.betterHome = function()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local feedkeys =
    -- move cursor to the real beginning of the line
        (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match("^%s*$")) and "<Home>" or
        -- move cursor to beginning of non-whitespace characters of the line
        (vim.api.nvim_get_mode().mode == "i" and "<C-o>^" or "^")

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), "n", false)
end

Core.compile_commands = {
    ["cpp"]  = "make\n",
    ["rust"] = "cargo build\n",
}
Core.codeCompile = function()
    local command = Core.compile_commands[vim.bo.filetype]
    if command then
        Core.toggleFloatTerminal(function() vim.api.nvim_feedkeys(command, "t", false) end)
    else
        Core.warn("Compile command is empty.")
    end
end

Core.float_terminal_opts = {
    buf = nil,
    win = nil,
    config = function()
        local width, height = math.floor(vim.o.columns * 0.7), math.floor(vim.o.lines * 0.7)
        local row, col = math.floor((vim.o.lines - height) / 2), math.floor((vim.o.columns - width) / 2)
        return {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded",
        }
    end
}
Core.toggleFloatTerminal = function(callback)
    local function showFloatWindow()
        Core.float_terminal_opts.win =
            vim.api.nvim_open_win(Core.float_terminal_opts.buf, true, Core.float_terminal_opts.config())
        vim.api.nvim_command("startinsert")

        if type(callback) == "function" then vim.defer_fn(callback, 100) end
    end

    if Core.float_terminal_opts.win and vim.api.nvim_win_is_valid(Core.float_terminal_opts.win) then
        vim.api.nvim_win_hide(Core.float_terminal_opts.win)
        Core.float_terminal_opts.win = nil
        return
    end

    if Core.float_terminal_opts.buf and vim.api.nvim_buf_is_valid(Core.float_terminal_opts.buf) then
        return showFloatWindow()
    end

    local filePath = vim.fn.expand("%:p:h")
    Core.float_terminal_opts.buf = vim.api.nvim_create_buf(false, true)
    showFloatWindow()
    vim.fn.termopen(vim.o.shell, {
        cwd = filePath,
        on_exit = function()
            vim.api.nvim_win_close(Core.float_terminal_opts.win, true)
            Core.float_terminal_opts.buf = nil
            Core.float_terminal_opts.win = nil
        end
    })
end

Core.info = function(msg) vim.notify(msg, vim.log.levels.INFO) end
Core.warn = function(msg) vim.notify(msg, vim.log.levels.WARN) end

Core.toggleWrap = function() vim.wo.wrap = not vim.wo.wrap end

return Core
