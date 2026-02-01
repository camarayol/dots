core.set_options {
    g = {
        mapleader               = ' ',
        maplocalleader          = ' ',
        fileencodings           = 'UTF-8,GBK,GB2312',
        loaded_netrw            = 1,
        loaded_netrwPlugin      = 1,
        loaded_perl_provider    = 0,
        loaded_ruby_provider    = 0,
        loaded_python3_provider = 0,
        loaded_node_provider    = 0,
    },
    opt = {
        fileencodings  = 'UTF-8,GBK,GB2312',
        mouse          = 'a',
        confirm        = true,
        number         = true,
        relativenumber = false,
        updatetime     = 300,
        showmode       = false,
        sidescrolloff  = 8,
        -- :h listchar
        list           = true,
        listchars      = { space = ' ', tab = '> ', trail = '·' },
        textwidth      = 160,
        showtabline    = 0,
        laststatus     = 0,
        timeoutlen     = 200,
        tabstop        = 4,
        shiftwidth     = 4,
        expandtab      = true,
        smartindent    = true,
        -- :h cinkeys-format
        cinkeys        = { ':', '0#', '!<Tab>' },
        termguicolors  = true,
        cursorline     = true,
        swapfile       = false,
        writebackup    = false,
        signcolumn     = 'yes',
        hlsearch       = true,
        incsearch      = true,
    }
}

vim.schedule(function()
    vim.opt.clipboard = 'unnamedplus'
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
end)
