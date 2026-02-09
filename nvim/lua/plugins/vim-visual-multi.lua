core.set_options {
    g = {
        VM_theme = 'iceblue',
        VM_highlight_matches = 'underline',
        VM_default_mappings = 0,
        VM_leader = '<Nop>',
        VM_maps = {
            ['Remove Region'  ] = 'q',
            ['Add Cursor Up'  ] = '<C-k>',
            ['Add Cursor Down'] = '<C-j>',
            ['Find Under'     ] = '<C-n>',
            ['Goto Prev'      ] = '<Nop>',
            ['Goto Next'      ] = '<Nop>',
        }
    }
}

return {
    source = 'https://github.com/mg979/vim-visual-multi',
}
