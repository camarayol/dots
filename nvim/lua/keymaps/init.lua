require('keymaps.terminal')

local smartHome = function()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local feedkeys =
    -- move cursor to the real beginning of the line
        (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match('^%s*$')) and '<Home>' or
        -- move cursor to beginning of non-whitespace characters of the line
        (vim.api.nvim_get_mode().mode == 'i' and '<C-o>^' or '^')

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), 'n', false)
end

local toggleWrap = function()
    vim.wo.wrap = not vim.wo.wrap
end

local hlCursorWord = function()
    local word = vim.fn.expand('<cword>')
    if word ~= '' then
        vim.cmd(string.format("let @/ = '%s'", word))
        vim.cmd('set hlsearch')
    end
end

local lineComment = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'n' or mode == 'i' then
        local line = vim.api.nvim_get_current_line()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        if not line:find('%S') then
            local cs = vim.bo.commentstring
            if cs == nil or cs == '' then
                return Core.warn("Option 'commentstring' is empty.")
            end
            local cursor_position = { row, col + cs:find('%%s') - 1 }
            local commentline = string.rep(' ', col) .. cs:gsub('%%s', '')
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, { commentline })
            vim.api.nvim_win_set_cursor(0, cursor_position)

            if mode == 'n' then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'n', false)
            end
        else
            require('vim._comment').toggle_lines(row, row)
        end
    else
        local srow = math.min(vim.fn.getpos('v')[2], vim.fn.getpos('.')[2])
        local erow = math.max(vim.fn.getpos('v')[2], vim.fn.getpos('.')[2])
        require('vim._comment').toggle_lines(srow, erow)
    end
end

Core.setKeyMaps {
    n = {
        ['<Leader>q']  = '<Cmd>qall<CR>',
        ['U']          = '<Cmd>redo<CR>',
        ['<C-a>']      = 'ggVG',
        ['<Home>']     = smartHome,

        ['<M-a>']      = '<C-o>',
        ['<M-d>']      = '<C-i>',
        ['<C-/>']      = lineComment,
        ['<C-_>']      = lineComment,

        ['<S-q>']      = '<Cmd>bdelete<CR>',
        ['<Tab>']      = '<Cmd>bnext<CR>',
        ['<S-Tab>']    = '<Cmd>bprevious<CR>',

        ['<M-j>']      = ':move .+1<CR>',
        ['<M-J>']      = ':copy .<CR>',
        ['<M-k>']      = ':move .-2<CR>',
        ['<M-K>']      = ':copy .-1<CR>',

        ['<M-z>']      = toggleWrap,

        ['<leader>t']  = '<Cmd>TerminalFloat<CR>',

        ['<leader>h']  = hlCursorWord,

        ['<leader>nh'] = '<Cmd>nohlsearch<CR>',

        ['<Leader>wh'] = '<Cmd>wincmd h<CR>',
        ['<Leader>wj'] = '<Cmd>wincmd j<CR>',
        ['<Leader>wk'] = '<Cmd>wincmd k<CR>',
        ['<Leader>wl'] = '<Cmd>wincmd l<CR>',

        ['<F2>']       = '<Cmd>Inspect<CR>',
    },
    i = {
        ['jk']      = '<Esc>',
        ['<Home>']  = smartHome,
        ['<M-i>']   = smartHome,
        ['<M-a>']   = '<End>',
        ['<M-h>']   = '<Left>',
        ['<M-l>']   = '<Right>',
        ['<S-Tab>'] = '<C-d>',
        ['<C-/>']   = lineComment,
        ['<C-_>']   = lineComment,
    },
    v = {
        ['<Home>']  = smartHome,
        ['<Tab>']   = '>gv',
        ['<S-Tab>'] = '<gv',
        ['<M-j>']   = ":move '>+1<CR>gv",
        ['<M-J>']   = ":copy '<-1<CR>gv",
        ['<M-k>']   = ":move '<-2<CR>gv",
        ['<M-K>']   = ":copy '><CR>gv",
        ['<C-/>']   = lineComment,
        ['<C-_>']   = lineComment,
    },
    t = {
        ['<Esc>'] = '<C-\\><C-n>'
    },
    c = {
        ['<M-j>'] = '<Down>',
        ['<M-k>'] = '<Up>',
    }
}
