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

Core.floatTerminalOpts = {
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
        Core.floatTerminalOpts.win =
            vim.api.nvim_open_win(Core.floatTerminalOpts.buf, true, Core.floatTerminalOpts.config())
        vim.api.nvim_command("startinsert")

        if type(callback) == "function" then vim.defer_fn(callback, 100) end
    end

    if Core.floatTerminalOpts.win and vim.api.nvim_win_is_valid(Core.floatTerminalOpts.win) then
        vim.api.nvim_win_hide(Core.floatTerminalOpts.win)
        Core.floatTerminalOpts.win = nil
        return
    end

    if Core.floatTerminalOpts.buf and vim.api.nvim_buf_is_valid(Core.floatTerminalOpts.buf) then
        return showFloatWindow()
    end

    local filePath = vim.fn.expand("%:p:h")
    Core.floatTerminalOpts.buf = vim.api.nvim_create_buf(false, true)
    showFloatWindow()
    vim.fn.termopen(vim.o.shell, {
        cwd = filePath,
        on_exit = function()
            vim.api.nvim_win_close(Core.floatTerminalOpts.win, true)
            Core.floatTerminalOpts.buf = nil
            Core.floatTerminalOpts.win = nil
        end
    })
end

local hlkind = { ui = "gui", fg = "guifg", bg = "guibg" }
Core.setHighlights = function(highlights)
    for group, args in pairs(highlights) do
        local command = string.format("highlight %s ", group)
        for arg, value in pairs(args) do
            command = command .. hlkind[arg] .. "=" .. value .. " "
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

Core.info = function(msg) vim.notify(msg, vim.log.levels.INFO) end
Core.warn = function(msg) vim.notify(msg, vim.log.levels.WARN) end

return Core
