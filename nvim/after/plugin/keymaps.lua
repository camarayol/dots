core.set_keymaps {
    n = {
        ['<Leader>q']  = '<Cmd>qall<CR>',
        ['U']          = '<Cmd>redo<CR>',
        ['<C-a>']      = 'ggVG',

        ['<M-a>']      = '<C-o>',
        ['<M-d>']      = '<C-i>',

        ['<S-q>']      = '<Cmd>bdelete<CR>',
        ['<Tab>']      = '<Cmd>bnext<CR>',
        ['<S-Tab>']    = '<Cmd>bprevious<CR>',

        ['<Leader>wh'] = '<Cmd>wincmd h<CR>',
        ['<Leader>wj'] = '<Cmd>wincmd j<CR>',
        ['<Leader>wk'] = '<Cmd>wincmd k<CR>',
        ['<Leader>wl'] = '<Cmd>wincmd l<CR>',

        ['<F2>']       = '<Cmd>Inspect<CR>',

        ['<M-j>']      = ':move .+1<CR>',
        ['<M-J>']      = ':copy .<CR>',
        ['<M-k>']      = ':move .-2<CR>',
        ['<M-K>']      = ':copy .-1<CR>',

        ['<M-z>']      = function() vim.wo.wrap = not vim.wo.wrap end,

        ['<Esc>']      = '<Cmd>nohlsearch<CR>',
        ['<Leader>nh'] = '<Cmd>nohlsearch<CR>',
        ['<Leader>h']  = function()
            local word = vim.fn.expand('<cword>')
            if word ~= '' then
                vim.cmd(string.format("let @/ = '%s'", word))
                vim.cmd('set hlsearch')
            end
        end,
    },
    i = {
        ['jk']      = '<Esc>',
        ['<M-a>']   = '<End>',
        ['<M-h>']   = '<Left>',
        ['<M-l>']   = '<Right>',
        ['<S-Tab>'] = '<C-d>',
    },
    v = {
        ['<M-j>']   = ":move '>+1<CR>gv",
        ['<M-J>']   = ":copy '<-1<CR>gv",
        ['<M-k>']   = ":move '<-2<CR>gv",
        ['<M-K>']   = ":copy '><CR>gv",
        ['<Tab>']   = '>gv',
        ['<S-Tab>'] = '<gv',
    },
    c = {
        ['<M-j>'] = '<Down>',
        ['<M-k>'] = '<Up>',
    }
}

core.set_mode_keymaps({ 'n', 'i', 'v' }, {
    ['<Home>'] = function()
        local _, col = unpack(vim.api.nvim_win_get_cursor(0))
        local feedkeys =
        -- move cursor to the real beginning of the line
            (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match('^%s*$')) and '<Home>' or
            -- move cursor to beginning of non-whitespace characters of the line
            (vim.api.nvim_get_mode().mode == 'i' and '<C-o>^' or '^')

        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), 'n', false)
    end,
    ['<C-/>'] = function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        require('vim._comment').toggle_lines(row, row)
    end,
    ['<C-_>'] = { '<C-/>', { noremap = false } },
})
