-- Nop
core.sk('n', '<C-u>', '<Nop>')
core.sk('n', '<C-r>', '<Nop>')
core.sk('n', '<C-d>', '<Nop>')
core.sk('n', '<C-f>', '<Nop>')
core.sk('n', '<C-b>', '<Nop>')
core.sk('n', '<C-o>', '<Nop>')
core.sk('n', '<C-i>', '<Nop>')
core.sk('i', '<C-n>', '<Nop>')
core.sk('i', '<C-p>', '<Nop>')
core.sk('i', '<C-x>', '<Nop>')


-- Normal
core.sk('n', '<Esc>', function()
    vim.cmd('nohlsearch')

    local mc = vim.api.nvim_create_namespace('nvim.multicursor')
    if mc then
        vim.api.nvim_buf_clear_namespace(0, mc, 0, -1)
    end
end)

core.sk('n', 'U', '<Cmd>redo<CR>')

core.sk('n', '<C-a>', 'ggVG')
core.sk('n', '<C-s>', '<Cmd>write<CR>')
core.sk('n', '<M-a>', '<C-o>')
core.sk('n', '<M-d>', '<C-i>')
core.sk('n', '<F2>',  '<Cmd>Inspect<CR>')
core.sk('n', '<M-z>', '<Cmd>set wrap!<CR>')
core.sk('n', '<C-h>', '10k')
core.sk('n', '<C-l>', '10j')

core.sk('n', '<Leader>w', '<C-w>', { noremap = false })

core.sk('n', '<Leader>h', function()
    local value = vim.fn.expand('<cword>')
    if value ~= '' then
        vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
        vim.cmd('set hlsearch')
    end
end)

core.sk('n', '<Leader>q', '<Cmd>bdelete<CR>')
core.sk('n', '<Tab>',     '<Cmd>silent! bnext<CR>')
core.sk('n', '<S-Tab>',   '<Cmd>silent! bprev<CR>')

core.sk('n', '<M-j>', ':move .+1<CR>')
core.sk('n', '<M-J>', ':copy .+0<CR>')
core.sk('n', '<M-k>', ':move .-2<CR>')
core.sk('n', '<M-K>', ':copy .-1<CR>')

core.sk('n', 'mm', '%', { noremap = false })

-- Insert
core.sk('i', 'jk', '<Cmd>stopinsert<CR>')

core.sk('i', '<C-v>', '<C-r>+')
core.sk('i', '<C-h>', '<Left>')
core.sk('i', '<C-j>', '<Down>')
core.sk('i', '<C-k>', '<Up>')
core.sk('i', '<C-l>', '<Right>')

core.sk('i', '<S-Tab>', function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local before = vim.api.nvim_get_current_line():sub(1, col)
    local whitespace = before:match('[ \t]+$') or ''

    local count = math.min(vim.bo.tabstop, #whitespace)
    if count > 0 then
        vim.api.nvim_buf_set_text(0, row - 1, col - count, row - 1, col, {})
        vim.api.nvim_win_set_cursor(0, { row, col - count })
    end
end)

-- Visual and Select
core.sk('x', 'p', '<Cmd>normal! "_dP<CR>')

core.sk('x', '<M-j>', ":move '>+1<CR>gv")
core.sk('x', '<M-J>', ":copy '<-1<CR>gv")
core.sk('x', '<M-k>', ":move '<-2<CR>gv")
core.sk('x', '<M-K>', ":copy '>+0<CR>gv")

core.sk('x', '<Tab>',   '>gv')
core.sk('x', '<S-Tab>', '<gv')

core.sk('x', 'n', function()
    local value = core.get_visual_text()
    if value == '' then return end
    vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
    vim.cmd('set hlsearch')
end)


-- Command
core.sk('c', '<M-h>', '<Left>')
core.sk('c', '<M-j>', '<Down>')
core.sk('c', '<M-k>', '<Up>')
core.sk('c', '<M-l>', '<Right>')

--- toggle comment
core.sk('n', '<C-/>', 'gcc',      { noremap = false })
core.sk('n', '<C-_>', 'gcc',      { noremap = false })
core.sk('i', '<C-_>', '<C-o>gcc', { noremap = false })
core.sk('i', '<C-/>', '<C-o>gcc', { noremap = false })
core.sk('x', '<C-/>', 'gcgv',     { noremap = false })
core.sk('x', '<C-_>', 'gcgv',     { noremap = false })

local function home()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- move cursor to the real beginning of the line
    local feedkeys = (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match('^%s*$')) and '<Home>' or
        -- move cursor to beginning of non-whitespace characters of the line
        (vim.api.nvim_get_mode().mode == 'i' and '<C-o>^' or '^')

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), 'n', false)
end

core.sk('n', '<Home>', home, { noremap = false })
core.sk('i', '<Home>', home, { noremap = false })
core.sk('x', '<Home>', home, { noremap = false })

--- yank code path
core.sk('n', '<C-y>', function()
    local path = string.format('%s#L%d', vim.fn.expand('%:p'), vim.fn.line('.'))
    vim.fn.setreg('*', path)
    vim.notify(path .. ' added to clipboard.')
end)

core.sk('x', '<C-y>', function()
    vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'x', true)
    local sline, eline = vim.fn.line("'<"), vim.fn.line("'>")
    local range = sline == eline and string.format('#L%d', sline) or
        string.format('#L%d-L%d', sline, eline)
    local path = string.format('%s%s', vim.fn.expand('%:p'), range)
    vim.fn.setreg('*', path)
    vim.notify(path .. ' added to clipboard.')
end)

core.sk('x', 'rn', '', {
    callback = function()
        local pattern = core.get_visual_text()
        if pattern == '' then return end
        string.gsub(pattern, '/', '\\/')

        local newstring = ''
        core.create_once_cursor_window {
            winopts = { title = 'Substitute', title_pos = 'center' },
            on_open = function()
                vim.cmd('startinsert!')
            end,
            on_exec = function()
                newstring = vim.api.nvim_get_current_line()
            end,
            on_exit = function()
                vim.cmd('stopinsert')
                local command = string.format(':%%s/%s/%s/gc', pattern, newstring:gsub('/', '\\/'))
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(command, true, false, true), 'n', false)
            end
        }
    end
})
