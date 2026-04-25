return {
    src = 'https://github.com/nvim-mini/mini.indentscope',
    config = function()
        core.nvim_set_highlights {
            ['MiniIndentscopeSymbol'] = { link = 'IndentScopeOther' },
        }
        require('mini.indentscope').setup {
            symbol = '│',
            draw = {
                delay = 0,
                priority = 2,
                animation = require('mini.indentscope').gen_animation.none(),
                predicate = function(scope) return not scope.body.is_incomplete end,
            },
            mappings = { object_scope = '', object_scope_with_border = '', goto_top = '', goto_bottom = '' },
            options = {
                border = 'both',
                indent_at_cursor = true,
                n_lines = 10000,
                try_as_border = false,
            }
        }
    end
}
