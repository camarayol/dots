vim.g.nvim_surround_no_mappings = true

return {
    src = 'https://github.com/kylechui/nvim-surround',
    config = function()
        core.nvim_set_highlights {
            ['NvimSurroundHighlight'] = { link = 'IndentScopeCurrent' },
        }

        core.set_keymaps('n', {
            ['ys'] = '<Plug>(nvim-surround-normal)',
            ['ds'] = '<Plug>(nvim-surround-delete)',
            ['cs'] = '<Plug>(nvim-surround-change)',
        })

        core.set_keymaps('x', {
            ['S'] = '<Plug>(nvim-surround-visual)',
        })

        require('nvim-surround').setup {}
    end
}
