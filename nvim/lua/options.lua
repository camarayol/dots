core.set_options {
    g = {
        -- Leader
        mapleader      = vim.keycode('<Space>'),
        maplocalleader = vim.keycode('<Space>'),

        -- Disable plugins
        loaded_netrw            = 1,
        loaded_netrwPlugin      = 1,
        loaded_perl_provider    = 0,
        loaded_ruby_provider    = 0,
        loaded_python3_provider = 0,
        loaded_node_provider    = 0,
    },
    opt = {
        -- Enable FileEncoding
        fileencodings = 'UTF-8,GBK,GB2312',

        -- Enable mouse
        mouse = 'a',

        -- Enable confirm while close unsaved buffer
        confirm = true,

        -- LineNumber
        number = false,
        relativenumber = false,

        updatetime = 300,

        -- Do Not show mode in COMMAND LINE
        showmode = false,
        ruler = false,
        cmdheight = 1,

        sidescrolloff = 8,

        -- WhiteSpace display characters
        list = true,
        listchars = { space = ' ', tab = '> ', trail = '·' },

        -- Wrap width
        textwidth   = 160,
        linebreak   = true,
        breakindent = true,

        showtabline = 0,

        laststatus = 0,

        timeoutlen = 200,

        -- TabStop
        tabstop = 4,
        shiftwidth = 4,

        -- Indent
        expandtab = true,
        smartindent = true,
        cinkeys = { ':', '0#', '!<Tab>' },

        termguicolors = true,

        -- Hilight CursorLine
        cursorline = false,

        -- Disable swapfile
        swapfile = false,

        -- Disable backupfile
        writebackup = false,

        -- Always draw the signcolumn
        signcolumn = 'yes',

        -- Highlight when typing search command
        hlsearch = true,
        incsearch = true,

        -- Do Not change screen position while moving through jumplist
        jumpoptions = 'view',

        showcmd = false,

        shortmess = 'ltToOCFIsS',

        -- Rounded window border
        winborder = 'rounded',

        -- Do Not add <EOL> at the end of file
        fixendofline = false,
    }
}

vim.opt.fillchars:append { diff = ' ', eob = ' ' }

vim.schedule(function()
    -- Enable system clipboard
    vim.opt.clipboard = 'unnamedplus'

    vim.opt.iskeyword:append('-')

    vim.opt.whichwrap:append('<,>,h,l')

    -- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic
    vim.diagnostic.config {
        severity_sort = true,
        -- vim.diagnostic.severity
        signs = { text = { '', '', '', '' } },
        -- vim.diagnostic.Opts.VirtualText
        virtual_text = { prefix = ' ', virt_text_pos = 'eol' }
    }

    vim.treesitter.language.register('json5', 'json')
end)
