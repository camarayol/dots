return {
    source = 'https://github.com/nvim-mini/mini.clue',
    config = function()
        require('mini.clue').setup {
            window = {
                delay = 100,
                config = { width = 'auto', border = 'rounded', title_pos = 'center' }
            },
            triggers = {
                { mode = 'n', keys = '<Bslash>' },
                { mode = 'n', keys = 'g' },
                { mode = 'n', keys = '[' },
                { mode = 'n', keys = ']' },
                { mode = { 'n', 'x' }, keys = '<Leader>' },
            },
        }
    end
}
