return {
    src = 'https://github.com/kylechui/nvim-surround',
    events = { 'CursorHold', 'CursorMoved' },
    before = function()
        vim.g.nvim_surround_no_mappings = true
    end,
    config = function()
        core.set_keymaps {
            { modes = 'n', lhs = 'ys', rhs = '<Plug>(nvim-surround-normal)' },
            { modes = 'n', lhs = 'ds', rhs = '<Plug>(nvim-surround-delete)' },
            { modes = 'n', lhs = 'cs', rhs = '<Plug>(nvim-surround-change)' },
            { modes = 'x', lhs = 'S',  rhs = '<Plug>(nvim-surround-visual)' },
        }

        require('nvim-surround').setup {}
    end
}
