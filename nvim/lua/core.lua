--- @diagnostic disable: lowercase-global, unused-local
core = {}

core.group = vim.api.nvim_create_augroup('core.default', { clear = true })

function core.hasfeature(feature)
    return vim.fn.has(feature) == 1
end

function core.set_options(opts)
    for t, o in pairs(opts) do
        for k, v in pairs(o) do vim[t][k] = v end
    end
end

function core.set_keymaps(modes, keymaps)
    modes = type(modes) == 'string' and { modes } or modes

    for lhs, opts in pairs(keymaps) do
        local rhs, buf = '', nil

        if type(opts) == 'string' then
            rhs, opts = opts, {}
        elseif type(opts) == 'function' then
            opts = { callback = opts }
        elseif type(opts) == 'table' then
            if type(opts.rhs) ~= 'nil' then rhs, opts.rhs = opts.rhs, nil end
            if type(opts.buf) ~= 'nil' then buf, opts.buf = opts.buf, nil end
        end

        opts = vim.tbl_extend('force', { nowait = false, silent = true, noremap = true }, opts)

        for _, mode in ipairs(modes) do
            if buf then
                vim.api.nvim_buf_set_keymap(buf, mode, lhs, rhs, opts)
            else
                vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
            end
        end
    end
end

function core.nvim_set_highlights(hl)
    for name, val in pairs(hl) do vim.api.nvim_set_hl(0, name, val) end
end

function core.create_autocommand(event, opts)
    if type(opts) == 'function' then
        opts = { callback = opts }
    end

    if type(opts) == 'table' then
        opts = vim.tbl_extend('force', { group = core.group }, opts)
    end

    return vim.api.nvim_create_autocmd(event, opts)
end

core.create_usercommand = vim.schedule_wrap(vim.api.nvim_create_user_command)

function core.get_visual_text()
    if vim.api.nvim_get_mode().mode ~= 'v' then return '' end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'x', true)
    local spos, epos = vim.fn.getpos("'<"), vim.fn.getpos("'>")
    return vim.api.nvim_buf_get_text(0, spos[2] - 1, spos[3] - 1, epos[2] - 1, epos[3], {})[1]
end

--- @class core.bwoptions
--- @field winopts? vim.api.keyset.win_config
--- @field on_open? function
--- @field on_exec? function
--- @field on_exit? function
--- @param opts core.bwoptions
function core.create_once_cursor_window(opts)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].filetype = opts.winopts.title
    vim.api.nvim_buf_set_name(buf, opts.winopts.title)

    opts.winopts = vim.tbl_extend('force', {
        row = 1, col = 0, height = 1, width = 30, relative = 'cursor', style = 'minimal'
    }, opts.winopts or {})

    local win = vim.api.nvim_open_win(buf, true, opts.winopts)

    if opts.on_open then opts.on_open(buf, win) end

    local function close()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end

    local function callback()
        if opts.on_exec then opts.on_exec(buf, win) end
        close()
        if opts.on_exit then opts.on_exit(buf, win) end
    end

    core.set_keymaps('n', {
        ['q']     = { buf = buf, callback = close },
        ['<Esc>'] = { buf = buf, callback = close },
    })

    core.set_keymaps('i', {
        ['<CR>']  = { buf = buf, callback = callback },
        ['<Esc>'] = { buf = buf, callback = close },
    })
end

return core
