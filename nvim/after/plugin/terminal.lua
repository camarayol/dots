local opts = {
    buf   = nil,
    win   = nil,
    style = nil,
    shell = vim.o.shell,
}

local cleanup = function()
    local win, buf = opts.win, opts.buf
    opts.win, opts.buf, opts.style = nil, nil, nil

    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
    end

    vim.api.nvim_del_augroup_by_name('core.Terminal')
end

local toggle_terminal_window = function(config)
    local style = config.relative == nil and 'split' or 'float'

    if opts.win and vim.api.nvim_win_is_valid(opts.win) then
        vim.api.nvim_win_hide(opts.win)
        opts.win = nil

        if opts.style == style then
            return false
        end
    end

    opts.win = vim.api.nvim_open_win(opts.buf, true, config)
    opts.style = style
    return true
end

local create_terminal_buffer = function()
    if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then return true end

    opts.buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_keymap(opts.buf, 'n', 'q', '', {
        callback = function()
            if opts.win and vim.api.nvim_win_is_valid(opts.win) then
                vim.api.nvim_win_hide(opts.win)
                opts.win = nil
            end
        end,
        noremap = true,
        silent = true
    })

    vim.api.nvim_buf_set_keymap(opts.buf, 't', '<Esc><Esc>', '<C-Bslash><C-n>', { noremap = true, silent = true })

    vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('core.Terminal', { clear = true }), buf = opts.buf, command = 'startinsert'
    })

    local cwd = vim.fn.expand('%:p:h')

    vim.api.nvim_buf_call(opts.buf, function()
        vim.fn.jobstart(opts.shell, { term = true, cwd = cwd, on_exit = cleanup })
    end)

    return true
end

local terminal = function(config, callback)
    if not create_terminal_buffer() then return end

    if toggle_terminal_window(config) then
        if type(callback) == 'function' then vim.defer_fn(callback, 100) end
    end
end

vim.api.nvim_create_user_command('CoreTerminalFloat', function()
    local width, height = math.floor(vim.o.columns * 0.7), math.floor(vim.o.lines * 0.7)
    local row, col = math.floor((vim.o.lines - height) / 2), math.floor((vim.o.columns - width) / 2)
    terminal {
        relative = 'editor',
        width    = width,
        height   = height,
        row      = row,
        col      = col,
        style    = 'minimal',
    }
end, {})

vim.api.nvim_create_user_command('CoreTerminalSplit', function() terminal { split = 'below' } end, {})

core.set_keymaps {
    { modes = 't', lhs = '<Esc><Esc>', rhs = '<C-Bslash><C-n>' },
    { modes = 't', lhs = '<C-w>',      rhs = '<C-Bslash><C-n><C-w>',       opts = { noremap = false } },
    { modes = 'n', lhs = '<Leader>tf', rhs = '<Cmd>CoreTerminalFloat<CR>', opts = { desc = 'Terminal float' } },
    { modes = 'n', lhs = '<Leader>tb', rhs = '<Cmd>CoreTerminalSplit<CR>', opts = { desc = 'Terminal below' } },
}
