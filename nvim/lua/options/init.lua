require('options.commands')

Core.setOptions {
    opt = {
        fileencodings  = 'UTF-8,GBK,GB2312',
        mouse          = 'a',
        number         = true,
        relativenumber = false,
        showmode       = false,
        sidescrolloff  = 8,
        list           = true, -- :h listchars
        listchars      = {
            space = ' ',
            tab   = '> ',
            trail = '·',
        },
        swapfile       = false,
        textwidth      = 160,
        showtabline    = 0,
        laststatus     = 0,
        timeoutlen     = 200,
        tabstop        = 4,
        shiftwidth     = 4,
        expandtab      = true,
        smartindent    = true,
        cinkeys        = ':,0#,!<Tab>', -- :h cinkeys-format
        termguicolors  = true,
        cursorline     = true,
        writebackup    = false,
        signcolumn     = 'yes',
        hlsearch       = true,
        incsearch      = true,
        clipboard      = 'unnamedplus',
    },
    g = {
        fileencodings           = 'UTF-8,GBK,GB2312',
        mapleader               = ' ',
        maplocalleader          = ' ',
        loaded_netrw            = 1,
        loaded_netrwPlugin      = 1,
        loaded_perl_provider    = 0,
        loaded_ruby_provider    = 0,
        loaded_python3_provider = 0,
        loaded_node_provider    = 0,
    },
}

vim.opt.iskeyword:append('-')
vim.opt.whichwrap:append('<,>,h,l')

-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic
vim.diagnostic.config {
    severity_sort = true,
    -- vim.diagnostic.severity
    signs = { text = { '', '', '', '' } },
    -- vim.diagnostic.Opts.VirtualText
    virtual_text = { prefix = '', virt_text_pos = 'eol' }
}

vim.treesitter.language.register('json5', 'json')
