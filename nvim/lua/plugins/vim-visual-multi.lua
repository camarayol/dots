core.set_options {
    g = {
        VM_theme = 'iceblue',
        VM_highlight_matches = 'underline',
        VM_default_mappings = 0,
        VM_maps = { ['Remove Region'] = 'q' }
    }
}

return {
    source = 'https://github.com/mg979/vim-visual-multi',
    config = function()
        core.set_mode_keymaps('n', {
            ['<C-k>'] = '<Plug>(VM-Add-Cursor-Up)',
            ['<C-j>'] = '<Plug>(VM-Add-Cursor-Down)',
            ['<C-n>'] = '<Plug>(VM-Find-Under)',
        })
    end
}
