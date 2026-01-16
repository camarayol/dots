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

local toggleFloatTerminal = function(callback)
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

Core.createUserCommand('TerminalFloat', toggleFloatTerminal)
