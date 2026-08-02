core.set_keymaps {
    { modes = { 'n', 'x', 'o' }, lhs = 'f',  rhs = '<Cmd>HopChar1AC<CR>', opts = { noremap = false } },
    { modes = { 'n', 'x', 'o' }, lhs = 'ff', rhs = '<Cmd>HopChar2AC<CR>', opts = { noremap = false } },
    { modes = { 'n', 'x', 'o' }, lhs = 'F',  rhs = '<Cmd>HopChar1BC<CR>', opts = { noremap = false } },
    { modes = { 'n', 'x', 'o' }, lhs = 'FF', rhs = '<Cmd>HopChar2BC<CR>', opts = { noremap = false } },
}

return {
    src = 'https://github.com/smoka7/hop.nvim',
    events = { 'CmdUndefined' },
    pattern = { 'HopChar1AC', 'HopChar1BC', 'HopChar2AC', 'HopChar2BC' },
    config = function()
        require('hop').setup {
            keys = 'etovxqpdygfblzhckisuran',
            multi_windows = true,
            create_hl_autocmd = false,
            teasing = false,
            reverse_distribution = true,
            virtual_cursor = false,
            dim_unmatched = true
        }
    end
}
