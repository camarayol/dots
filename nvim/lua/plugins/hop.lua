return {
    src = 'https://github.com/smoka7/hop.nvim',
    version = vim.version.range('*'),
    config = function()
        local hop = require('hop')

        core.set_keymaps({ 'n', 'x', 'o' }, {
            ['f'] = { callback = function() hop.hint_char1 { direction = 2 } end, noremap = false },
            ['F'] = { callback = function() hop.hint_char1 { direction = 1 } end, noremap = false },
        })

        hop.setup {
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
