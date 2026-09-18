--- @param opts vim.api.keyset.keymap?
local sk = function(mode, lhs, rhs, opts)
    opts = vim.tbl_extend('force', { noremap = true, silent = true }, opts or {})
    vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

-- Nop
sk('n', '<C-u>', '<Nop>')
sk('n', '<C-r>', '<Nop>')
sk('n', '<C-u>', '<Nop>')
sk('n', '<C-d>', '<Nop>')
sk('n', '<C-f>', '<Nop>')
sk('n', '<C-b>', '<Nop>')
sk('n', '<C-o>', '<Nop>')
sk('n', '<C-i>', '<Nop>')
sk('i', '<C-n>', '<Nop>')
sk('i', '<C-p>', '<Nop>')
sk('i', '<C-x>', '<Nop>')


-- Normal
sk('n', '<Esc>', '', {
    callback = function()
        vim.opt.hlsearch = false

        local mc = vim.api.nvim_create_namespace('nvim.multicursor')
        if mc then
            vim.api.nvim_buf_clear_namespace(0, mc, 0, -1)
        end
    end
})

--- multicursor
--- Q    Toggles a multicursor at the current cursor position
--- q=   Toggles follow-mode
--- gQ   Restores the previous multicursors
if vim.fn.has('nvim-0.13') == 1 then
local function is_multicursor()
    local ns = vim.api.nvim_create_namespace('nvim.multicursor')
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))

    for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})) do
        if mark[2] == row - 1 and mark[3] == col then
            return true
        end
    end

    return false
end

sk('n', '<C-j>', '', {
    expr = true,
    replace_keycodes = true,
    callback = function()
        return is_multicursor() and 'j' or 'QjQ'
    end,
})

sk('n', '<C-k>', '', {
    expr = true,
    replace_keycodes = true,
    callback = function()
        return is_multicursor() and 'k' or 'QkQ'
    end,
})

sk('n', 'q', '', {
    expr = true,
    replace_keycodes = true,
    callback = function()
        return is_multicursor() and 'Q' or 'q'
    end,
})
end

sk('n', 'U', '<Cmd>redo<CR>')

sk('n', '<C-a>', 'ggVG')
sk('n', '<C-s>', '<Cmd>write<CR>')
sk('n', '<M-a>', '<C-o>')
sk('n', '<M-d>', '<C-i>')
sk('n', '<F2>',  '<Cmd>Inspect<CR>')
sk('n', '<M-z>', '<Cmd>set wrap!<CR>')
sk('n', '<C-h>', '10k')
sk('n', '<C-l>', '10j')

sk('n', '<Leader>w', '<C-w>', { noremap = false })

sk('n', '<Leader>h', '', {
    callback = function()
        local value = vim.fn.expand('<cword>')
        if value ~= '' then
            vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
            vim.cmd('set hlsearch')
        end
    end
})

sk('n', '<Leader>q', '<Cmd>bdelete<CR>')
sk('n', '<Tab>',     '<Cmd>silent! bnext<CR>')
sk('n', '<S-Tab>',   '<Cmd>silent! bprev<CR>')

sk('n', '<M-j>', ':move .+1<CR>')
sk('n', '<M-J>', ':copy .+0<CR>')
sk('n', '<M-k>', ':move .-2<CR>')
sk('n', '<M-K>', ':copy .-1<CR>')

sk('n', 'mm', '%', { noremap = false })

sk('n', '<Leader>f', '', {
    callback = function()
        if vim.bo.buftype == '' and vim.api.nvim_buf_get_name(0) == '' then
            vim.cmd('Explore')
        else
            vim.cmd('Lexplore')
        end
    end
})

-- Insert
sk('i', 'jk', '<Cmd>stopinsert<CR>')

sk('i', '<C-v>', '<C-r>+')
sk('i', '<M-h>', '<Left>')
sk('i', '<M-l>', '<Right>')

sk('i', '<S-Tab>', '', {
    callback = function()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local before = vim.api.nvim_get_current_line():sub(1, col)
        local whitespace = before:match('[ \t]+$') or ''

        local count = math.min(vim.bo.tabstop, #whitespace)
        if count > 0 then
            vim.api.nvim_buf_set_text(0, row - 1, col - count, row - 1, col, {})
            vim.api.nvim_win_set_cursor(0, { row, col - count })
        end
    end,
})

-- Visual and Select
sk('x', 'p', '<Cmd>normal! "_dP<CR>')

sk('x', '<M-j>', ":move '>+1<CR>gv")
sk('x', '<M-J>', ":copy '<-1<CR>gv")
sk('x', '<M-k>', ":move '<-2<CR>gv")
sk('x', '<M-K>', ":copy '>+0<CR>gv")

sk('x', '<Tab>',   '>gv')
sk('x', '<S-Tab>', '<gv')

sk('x', 'n', '', {
    callback = function()
        local value = core.get_visual_text()
        if value == '' then return end
        vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
        vim.cmd('set hlsearch')
    end
})


-- Command
sk('c', '<M-h>', '<Left>')
sk('c', '<M-j>', '<Down>')
sk('c', '<M-k>', '<Up>')
sk('c', '<M-l>', '<Right>')

--- toggle comment
sk('n', '<C-/>', 'gcc',      { noremap = false })
sk('n', '<C-_>', 'gcc',      { noremap = false })
sk('i', '<C-/>', '<C-o>gcc', { noremap = false })
sk('i', '<C-_>', '<C-o>gcc', { noremap = false })
sk('x', '<C-/>', 'gcgv',     { noremap = false })
sk('x', '<C-_>', 'gcgv',     { noremap = false })

local function home()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    -- move cursor to the real beginning of the line
    local feedkeys = (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match('^%s*$')) and '<Home>' or
        -- move cursor to beginning of non-whitespace characters of the line
        (vim.api.nvim_get_mode().mode == 'i' and '<C-o>^' or '^')

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), 'n', false)
end

sk('n', '<Home>', '', { noremap = false, callback = home })
sk('i', '<Home>', '', { noremap = false, callback = home })
sk('x', '<Home>', '', { noremap = false, callback = home })

--- yank code path
sk('n', '<C-y>', '', {
    callback = function()
        local path = string.format('%s#L%d', vim.fn.expand('%:p'), vim.fn.line('.'))
        vim.fn.setreg('*', path)
        vim.notify(path .. ' added to clipboard.')
    end
})

sk('x', '<C-y>', '', {
    callback = function()
        vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'x', true)
        local sline, eline = vim.fn.line("'<"), vim.fn.line("'>")
        local range = sline == eline and string.format('#L%d', sline) or
            string.format('#L%d-L%d', sline, eline)
        local path = string.format('%s%s', vim.fn.expand('%:p'), range)
        vim.fn.setreg('*', path)
        vim.notify(path .. ' added to clipboard.')
    end
})

sk('x', 'rn', '', {
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
