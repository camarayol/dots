--- @diagnostic disable: lowercase-global
core = {}

core.group = vim.api.nvim_create_augroup('core.default', { clear = true })

core.set_options = function(opts)
    for t, o in pairs(opts) do
        for k, v in pairs(o) do vim[t][k] = v end
    end
end

--- @type fun(mode: string|string[], keymaps: table)
core.set_mode_keymaps = vim.schedule_wrap(function(mode, keymaps)
    for lhs, v in pairs(keymaps) do
        local rhs = type(v) == 'table' and v[1] or v
        local opts = vim.tbl_extend('force', { noremap = true, silent = true },
            type(v) == 'table' and v[2] or {})
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end)

core.set_keymaps = function(mdkeymaps)
    for mode, keymaps in pairs(mdkeymaps) do core.set_mode_keymaps(mode, keymaps) end
end

--- @param event any
--- @param pattern? string|string[]
--- @param opts function|vim.api.keyset.create_autocmd
core.create_autocommand = function(event, pattern, opts)
    if type(opts) == 'function' then opts = { callback = opts } end
    opts = vim.tbl_extend('force', { group = core.group, pattern = pattern }, opts)
    vim.api.nvim_create_autocmd(event, opts)
end

--- @type fun(name: string, command: string|fun(args: vim.api.keyset.create_user_command.command_args), opts: vim.api.keyset.user_command)
core.create_usercommand = vim.schedule_wrap(vim.api.nvim_create_user_command)

---@param path string
core.prepend_env_path = function(path)
    local expanded_path = vim.fn.fnamemodify(vim.fn.expand(path), ':p:h')

    if vim.fn.isdirectory(expanded_path) == 0 then return end

    local sep = vim.fn.has('win32') and ';' or ':'

    local current_path = vim.env.PATH
    local pattern = '(^|' .. sep .. ')' .. vim.pesc(expanded_path) .. '($|' .. sep .. ')'
    if string.find(current_path, pattern) then return end

    vim.env.PATH = expanded_path .. sep .. current_path
end


--- @class core.bwoptions
--- @field winopts? vim.api.keyset.win_config
--- @field on_open? function
--- @field on_exec? function
--- @field on_exit? function
--- @param opts core.bwoptions
core.create_once_cursor_window = function(opts)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].bufhidden = 'wipe'

    opts.winopts = vim.tbl_extend('force', {
        row = 1, col = 0, height = 1, width = 50, relative = 'cursor', style = 'minimal', border = 'rounded'
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

    core.set_keymaps {
        n = {
            ['q']     = { close, { buffer = buf } },
            ['<Esc>'] = { close, { buffer = buf } },
        },
        i = {
            ['<Esc>'] = { close, { buffer = buf } },
            ['<CR>']  = { callback, { buffer = buf } },
        }
    }
end

return core
