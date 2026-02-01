local opts = {
    buf = nil,
    win = nil,
}

local terminal = function(config, callback)
    -- hide the existing terminal window
    if opts.win and vim.api.nvim_win_is_valid(opts.win) then
        vim.api.nvim_win_hide(opts.win)
        opts.win = nil
        return
    end

    if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
        -- create a new window to show the existing terminal buffer
        opts.win = vim.api.nvim_open_win(opts.buf, true, config)
    else
        -- create a new terminal buffer
        opts.buf = vim.api.nvim_create_buf(false, true)
        opts.win = vim.api.nvim_open_win(opts.buf, true, config)
        vim.fn.jobstart(vim.o.shell, {
            term = true,
            cwd = vim.fn.expand('%:p:h'),
            on_exit = function()
                vim.api.nvim_win_close(opts.win, true)
                opts.buf, opts.win = nil, nil
            end
        })
    end

    vim.cmd('startinsert')
    if type(callback) == 'function' then vim.defer_fn(callback, 100) end
end

core.create_usercommand('CoreTerminalFloat', function()
    local width, height = math.floor(vim.o.columns * 0.7), math.floor(vim.o.lines * 0.7)
    local row, col = math.floor((vim.o.lines - height) / 2), math.floor((vim.o.columns - width) / 2)
    terminal {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    }
end, {})

core.create_usercommand('CoreTerminalSplit', function() terminal { split = 'below' } end, {})

core.set_keymaps {
    n = {
        ['<Leader>t'] = '<Cmd>CoreTerminalFloat<CR>'
    },
    t = {
        ['<Esc>'] = '<C-\\><C-n>'
    }

}
