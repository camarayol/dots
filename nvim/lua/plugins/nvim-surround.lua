vim.g.nvim_surround_no_mappings = true

return {
    src = 'https://github.com/kylechui/nvim-surround',
    config = function()
        core.set_keymaps {
            n = {
                ['ys'] = { '<Plug>(nvim-surround-normal)', { desc = '[nvim-surround] insert' } },
                ['ds'] = { '<Plug>(nvim-surround-delete)', { desc = '[nvim-surround] delete' } },
                ['cs'] = { '<Plug>(nvim-surround-change)', { desc = '[nvim-surround] change' } },
            },
            x = {
                ['s']  = { '<Plug>(nvim-surround-visual)', { desc = '[nvim-surround] insert' } },
            }
        }

        require('nvim-surround').setup {}
    end
}
