core.set_keymaps {
    { modes = 'n', lhs = '<C-r>',     rhs = '<Nop>' },
    { modes = 'n', lhs = '<C-u>',     rhs = '<Nop>' },
    { modes = 'n', lhs = '<C-d>',     rhs = '<Nop>' },
    { modes = 'n', lhs = '<C-f>',     rhs = '<Nop>' },
    { modes = 'n', lhs = '<C-b>',     rhs = '<Nop>' },
    { modes = 'n', lhs = '<C-o>',     rhs = '<Nop>' },
    { modes = 'n', lhs = '<C-i>',     rhs = '<Nop>' },
    { modes = 'i', lhs = '<C-n>',     rhs = '<Nop>' },
    { modes = 'i', lhs = '<C-p>',     rhs = '<Nop>' },
    { modes = 'i', lhs = '<C-x>',     rhs = '<Nop>' },

    { modes = 'i', lhs = 'jk',        rhs = '<Cmd>stopinsert<CR>', opts = { desc = 'Exit insert mode' } },
    { modes = 'n', lhs = '<Leader>q', rhs = '<Cmd>qall<CR>',       opts = { desc = 'Exit' } },
    { modes = 'n', lhs = 'U',         rhs = '<Cmd>redo<CR>',       opts = { desc = 'Redo' } },
    { modes = 'n', lhs = '<C-h>',     rhs = '10k',                 opts = { desc = 'Quick move up' } },
    { modes = 'n', lhs = '<C-l>',     rhs = '10j',                 opts = { desc = 'Quick move down' } },
    { modes = 'n', lhs = '<C-a>',     rhs = 'ggVG',                opts = { desc = 'Select all' } },
    { modes = 'n', lhs = '<C-s>',     rhs = '<Cmd>write<CR>',      opts = { desc = 'Write' } },
    { modes = 'n', lhs = '<M-a>',     rhs = '<C-o>',               opts = { desc = 'Go to older cursor position' } },
    { modes = 'n', lhs = '<M-d>',     rhs = '<C-i>',               opts = { desc = 'Go to newer cursor position' } },
    { modes = 'n', lhs = '<F2>',      rhs = '<Cmd>Inspect<CR>',    opts = { desc = 'Inspect' } },
    { modes = 'n', lhs = '<M-z>',     rhs = '<Cmd>set wrap!<CR>',  opts = { desc = 'Toggle wrap' } },
    {
        modes = 'n', lhs = '<Esc>', rhs = [[v:hlsearch ? "\<Cmd>nohlsearch\<CR>" : "\<Esc>"]],
        opts = { desc = 'Nohlsearch', expr = true }
    },
    {
        modes = 'n', lhs = '<Leader>w', rhs = '<C-w>', opts = { noremap = false, desc = 'Window commands' }
    },
    {
        modes = 'n', lhs = '<Leader>h',
        rhs = function()
            local value = vim.fn.expand('<cword>')
            if value ~= '' then
                vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
                vim.cmd('set hlsearch')
            end
        end,
        opts = { desc = 'Search word under cursor' }
    },
    {
        modes = 'n', lhs = '<S-q>',
        rhs = function()
            if vim.bo.modifiable and not vim.wo.winfixbuf then
                vim.cmd('bdelete')
            end
        end,
        opts = { desc = 'Delete buffer' }
    },
    {
        modes = 'n', lhs = '<Tab>',
        rhs = function()
            if vim.bo.modifiable and not vim.wo.winfixbuf then
                vim.cmd('bnext')
            end
        end,
        opts = { desc = 'Next buffer' }
    },
    {
        modes = 'n', lhs = '<S-Tab>',
        rhs = function()
            if vim.bo.modifiable and not vim.wo.winfixbuf then
                vim.cmd('bprevious')
            end
        end,
        opts = { desc = 'Previous buffer' }
    },
    {
        modes = 'v', lhs = 'n',
        rhs = function()
            local value = core.get_visual_text()
            if value == '' then return end
            vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
            vim.cmd('set hlsearch')
        end,
        opts = { desc = 'Search visual selection' }
    },
    {
        modes = 'v', lhs = 'rn',
        rhs = function()
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
        end,
        opts = { desc = 'Substitute visual selection' }
    },

    { modes = 'i', lhs = '<M-h>', rhs = '<Left>',           opts = { desc = 'Move left' } },
    { modes = 'i', lhs = '<M-l>', rhs = '<Right>',          opts = { desc = 'Move right' } },

    { modes = 'n', lhs = '<M-j>', rhs = ':move .+1<CR>',    opts = { desc = 'Move cursor line down' } },
    { modes = 'n', lhs = '<M-J>', rhs = ':copy .+0<CR>',    opts = { desc = 'Copy cursor line down' } },
    { modes = 'n', lhs = '<M-k>', rhs = ':move .-2<CR>',    opts = { desc = 'Move cursor line up' } },
    { modes = 'n', lhs = '<M-K>', rhs = ':copy .-1<CR>',    opts = { desc = 'Copy cursor line up' } },

    { modes = 'x', lhs = '<M-j>', rhs = ":move '>+1<CR>gv", opts = { desc = 'Move selection lines down' } },
    { modes = 'x', lhs = '<M-J>', rhs = ":copy '<-1<CR>gv", opts = { desc = 'Copy selection lines down' } },
    { modes = 'x', lhs = '<M-k>', rhs = ":move '<-2<CR>gv", opts = { desc = 'Move selection lines up' } },
    { modes = 'x', lhs = '<M-K>', rhs = ":copy '>+0<CR>gv", opts = { desc = 'Copy selection lines up' } },

    {
        modes = 'i', lhs = '<S-Tab>',
        rhs = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local before = vim.api.nvim_get_current_line():sub(1, col)
            local whitespace = before:match('[ \t]+$') or ''

            local count = math.min(vim.bo.tabstop, #whitespace)
            if count > 0 then
                vim.api.nvim_buf_set_text(0, row - 1, col - count, row - 1, col, {})
                vim.api.nvim_win_set_cursor(0, { row, col - count })
            end
        end,
        opts = { desc = 'Remove indentation' }
    },

    { modes = 'v', lhs = '<Tab>',   rhs = '>gv',      opts = { desc = 'Indent right' } },
    { modes = 'v', lhs = '<S-Tab>', rhs = '<gv',      opts = { desc = 'Indent left' } },

    { modes = 'n', lhs = '<C-/>',   rhs = 'gcc',      opts = { noremap = false, desc = 'Toggle comment line' } },
    { modes = 'i', lhs = '<C-/>',   rhs = '<C-o>gcc', opts = { noremap = false, desc = 'Toggle comment line' } },
    { modes = 'v', lhs = '<C-/>',   rhs = 'gc',       opts = { noremap = false, desc = 'Toggle comment selection' } },
    {
        modes = { 'n', 'i', 'v' }, lhs = '<C-_>', rhs = '<C-/>', opts = { noremap = false, desc = 'Toggle comment (alias)' }
    },

    { modes = 'c', lhs = '<M-h>', rhs = '<Left>',  opts = { noremap = false, silent = false, desc = 'Move left' } },
    { modes = 'c', lhs = '<M-j>', rhs = '<Down>',  opts = { noremap = false, silent = false, desc = 'Move down' } },
    { modes = 'c', lhs = '<M-k>', rhs = '<Up>',    opts = { noremap = false, silent = false, desc = 'Move up' } },
    { modes = 'c', lhs = '<M-l>', rhs = '<Right>', opts = { noremap = false, silent = false, desc = 'Move right' } },

    { modes = 'n', lhs = 'mm',    rhs = '%',       opts = { noremap = false, desc = '%' } },

    {
        modes = { 'n', 'i', 'v' }, lhs = '<Home>',
        rhs = function()
            local _, col = unpack(vim.api.nvim_win_get_cursor(0))
            -- move cursor to the real beginning of the line
            local feedkeys = (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match('^%s*$')) and '<Home>' or
                -- move cursor to beginning of non-whitespace characters of the line
                (vim.api.nvim_get_mode().mode == 'i' and '<C-o>^' or '^')

            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), 'n', false)
        end,
        opts = { noremap = false, desc = 'Smart line home' }
    },
    {
        modes = 'n', lhs = '<C-y>',
        rhs = function()
            local path = string.format('%s#L%d', vim.fn.expand('%:p'), vim.fn.line('.'))
            vim.fn.setreg('*', path)
            vim.notify(path .. ' added to clipboard.')
        end,
        opts = { desc = 'Copy file:line' }
    },
    {
        modes = 'v', lhs = '<C-y>',
        rhs = function()
            vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'x', true)
            local sline, eline = vim.fn.line("'<"), vim.fn.line("'>")
            local range = sline == eline and string.format('#L%d', sline) or
                string.format('#L%d-L%d', sline, eline)
            local path = string.format('%s%s', vim.fn.expand('%:p'), range)
            vim.fn.setreg('*', path)
            vim.notify(path .. ' added to clipboard.')
        end,
        opts = { desc = 'Copy selection range' }
    }
}
