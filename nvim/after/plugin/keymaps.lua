core.set_keymaps('n', {
    -- Exit Neovim
    ['<Leader>q'] = '<Cmd>qall<CR>',

    -- Redo
    ['<C-r>']     = '<Nop>',
    ['U']         = '<Cmd>redo<CR>',

    -- Scroll window
    ['<C-u>']     = '<Nop>',
    ['<C-d>']     = '<Nop>',
    ['<C-f>']     = '<Nop>',
    ['<C-b>']     = '<Nop>',
    ['<C-h>']     = '<PageUp>',
    ['<C-l>']     = '<PageDown>',

    -- Select all
    ['<C-a>']     = 'ggVG',

    -- Write
    ['<C-s>']     = '<Cmd>write<CR>',

    -- Goto Prev/Next Jumplist
    ['<C-o>']     = '<Nop>',
    ['<C-i>']     = '<Nop>',
    ['<M-a>']     = '<C-o>',
    ['<M-d>']     = '<C-i>',

    -- Inspect
    ['<F2>']      = '<Cmd>Inspect<CR>',

    -- Toggle Wrap Lines
    ['<M-z>']     = function() vim.wo.wrap = not vim.wo.wrap end,

    -- Toggle hlsearch/nohlsearch
    ['<Esc>']     = '<Cmd>nohlsearch<CR>',
    ['<Leader>h'] = function()
        local value = vim.fn.expand('<cword>')
        if value ~= '' then
            vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
            vim.cmd('set hlsearch')
        end
    end,
})

-- Switch window
core.set_keymaps('n', {
    ['<Leader>w'] = { rhs = '<C-w>', noremap = false },
})

-- Close/Switch Buffer
core.set_keymaps('n', {
    ['<S-q>']   = function()
        if vim.bo.modifiable and not vim.wo.winfixbuf then
            vim.cmd('bdelete')
        end
    end,
    ['<Tab>']   = function()
        if vim.bo.modifiable and not vim.wo.winfixbuf then
            vim.cmd('bnext')
        end
    end,
    ['<S-Tab>'] = function()
        if vim.bo.modifiable and not vim.wo.winfixbuf then
            vim.cmd('bprevious')
        end
    end,
})

core.set_keymaps('i', {
    -- Exit to NORMAL mode
    ['jk']    = function() vim.cmd('stopinsert') end,

    ['<C-n>'] = '<Nop>',
    ['<C-p>'] = '<Nop>',

    -- Move Left/Right in INSERT mode
    ['<M-h>'] = '<Left>',
    ['<M-l>'] = '<Right>',
})

core.set_keymaps('v', {
    -- Search selected text
    ['n'] = function()
        local value = core.get_visual_text()
        if value == '' then return end
        vim.fn.setreg('/', '\\V' .. vim.fn.escape(value, '\\'))
        vim.cmd('set hlsearch')
    end,

    -- Substitute Rename
    ['rn'] = function()
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

-- Move/Copy Line Up/Down
core.set_keymaps('n', {
    ['<M-j>'] = ':move .+1<CR>',
    ['<M-J>'] = ':copy .<CR>',
    ['<M-k>'] = ':move .-2<CR>',
    ['<M-K>'] = ':copy .-1<CR>',
})

-- Move/Copy Block Up/Down
core.set_keymaps('v', {
    ['<M-j>'] = ":move '>+1<CR>gv",
    ['<M-J>'] = ":copy '<-1<CR>gv",
    ['<M-k>'] = ":move '<-2<CR>gv",
    ['<M-K>'] = ":copy '><CR>gv",
})

-- Indent
core.set_keymaps('i', {
    ['<S-Tab>'] = '<C-d>',
})
core.set_keymaps('v', {
    ['<Tab>']   = '>gv',
    ['<S-Tab>'] = '<gv',
})

-- Toggle Comment/Uncomment
core.set_keymaps('n', {
    ['<C-/>'] = { rhs = 'gcc',   noremap = false },
    ['<C-_>'] = { rhs = '<C-/>', noremap = false }
})
core.set_keymaps('i', {
    ['<C-/>'] = { rhs = '<C-o>gcc', noremap = false },
    ['<C-_>'] = { rhs = '<C-/>',    noremap = false },
})
core.set_keymaps('v', {
    ['<C-/>'] = { rhs = 'gc',    noremap = false },
    ['<C-_>'] = { rhs = '<C-/>', noremap = false },
})

-- Move cursor in COMMAND mode
core.set_keymaps('c', {
    ['<M-h>'] = { rhs = '<Left>',  noremap = false, silent = false },
    ['<M-j>'] = { rhs = '<Down>',  noremap = false, silent = false },
    ['<M-k>'] = { rhs = '<Up>',    noremap = false, silent = false },
    ['<M-l>'] = { rhs = '<Right>', noremap = false, silent = false },
})

-- Home
core.set_keymaps({ 'n', 'i', 'v' }, {
    ['<Home>'] = {
        noremap = false,
        callback = function()
            local _, col = unpack(vim.api.nvim_win_get_cursor(0))
            local feedkeys =
                -- move cursor to the real beginning of the line
                (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match('^%s*$')) and '<Home>' or
                -- move cursor to beginning of non-whitespace characters of the line
                (vim.api.nvim_get_mode().mode == 'i' and '<C-o>^' or '^')

            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), 'n', false)
        end,
    }
})

-- Yank current file path to register *
core.set_keymaps('n', {
    ['<C-y>'] = function()
        local path = string.format('%s#L%d', vim.fn.expand('%:p'), vim.fn.line('.'))
        vim.fn.setreg('*', path)
        vim.notify(path .. ' added to clipboard.')
    end
})
core.set_keymaps('v', {
    ['<C-y>'] = function()
        vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'x', true)
        local sline, eline = vim.fn.line("'<"), vim.fn.line("'>")
        local range = sline == eline and string.format('#L%d', sline) or
            string.format('#L%d-L%d', sline, eline)
        local path = string.format('%s%s', vim.fn.expand('%:p'), range)
        vim.fn.setreg('*', path)
        vim.notify(path .. ' added to clipboard.')
    end,
})
