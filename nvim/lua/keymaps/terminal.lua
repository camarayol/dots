local terminal_opts = {
    buf = nil,
    win = nil,
}

local terminal = function(config, callback)
    -- hide the existing terminal window 't.win'
    if terminal_opts.win and vim.api.nvim_win_is_valid(terminal_opts.win) then
        vim.api.nvim_win_hide(terminal_opts.win)
        terminal_opts.win = nil
        return
    end

    if terminal_opts.buf and vim.api.nvim_buf_is_valid(terminal_opts.buf) then
        -- create a new window to show the existing terminal buffer 't.buf'
        terminal_opts.win = vim.api.nvim_open_win(terminal_opts.buf, true, config)
    else
        -- create a new terminal buffer
        terminal_opts.buf = vim.api.nvim_create_buf(false, true)
        terminal_opts.win = vim.api.nvim_open_win(terminal_opts.buf, true, config)
        vim.fn.jobstart(vim.o.shell, {
            term = true,
            cwd = vim.fn.expand('%:p:h'),
            on_exit = function()
                vim.api.nvim_win_close(terminal_opts.win, true)
                terminal_opts.buf, terminal_opts.win = nil, nil
            end
        })
    end

    vim.cmd('startinsert')
    if type(callback) == "function" then vim.defer_fn(callback, 100) end
end

Core.createUserCommand('TerminalFloat', function()
    local width, height = math.floor(vim.o.columns * 0.7), math.floor(vim.o.lines * 0.7)
    local row, col = math.floor((vim.o.lines - height) / 2), math.floor((vim.o.columns - width) / 2)
    terminal {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    }
end)

Core.createUserCommand("TerminalSplit", function()
    terminal { split = 'below' }
end)
