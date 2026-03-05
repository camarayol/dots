vim.g.nvim_surround_no_mappings = true

return {
    source = 'https://github.com/kylechui/nvim-surround',
    config = function()
        core.set_keymaps {
            n = {
                ['s']  = '<Nop>',
                ['sa'] = { '<Plug>(nvim-surround-normal)', { desc = '[nvim-surround] insert' } },
                ['sd'] = { '<Plug>(nvim-surround-delete)', { desc = '[nvim-surround] delete' } },
                ['sr'] = { '<Plug>(nvim-surround-change)', { desc = '[nvim-surround] change' } },
            },
            x = {
                ['s']  = '<Nop>',
                ['sa'] = { '<Plug>(nvim-surround-visual)', { desc = '[nvim-surround] insert' } },
            }
        }

        require('nvim-surround').setup {}
    end
}
