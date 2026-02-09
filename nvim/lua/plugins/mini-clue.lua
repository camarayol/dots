return {
    source = 'https://github.com/nvim-mini/mini.clue',
    config = function()
        local miniclue = require('mini.clue')
        miniclue.setup {
            window = {
                delay = 100,
                config = { width = 'auto', border = 'rounded', title_pos = 'center' }
            },
            triggers = {
                { mode = { 'n', 'x' }, keys = '<Leader>' },
                { mode = { 'n', 'x' }, keys = 'z' },
                { mode = { 'n', 'x' }, keys = 'g' },
                { mode = { 'n', 'x' }, keys = '"' },
                { mode = { 'n', 'x' }, keys = "'" },
                { mode = { 'n', 'x' }, keys = '`' },
                { mode = 'n',          keys = '<Bslash>' },
                { mode = 'n',          keys = '<C-w>' },
                { mode = 'n',          keys = '[' },
                { mode = 'n',          keys = ']' },
                { mode = { 'i', 'c' }, keys = '<C-r>' },
                { mode = 'i',          keys = '<C-x>' },
            },
            clues = {
                miniclue.gen_clues.square_brackets(),
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),
            }
        }
    end
}
