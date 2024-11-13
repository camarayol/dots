local Core = require("core")

local options = {
    opt = {
        fileencodings  = "UTF-8,GBK,GB2312", -- file encoding
        mouse          = "a",                -- mouse support
        number         = true,               -- show line number
        relativenumber = true,               -- show relative line number
        showmode       = false,              -- do not show mode on the last line(NORMAL INSERT ...)
        sidescrolloff  = 8,                  --
        list           = true,               -- show 'space' 'tab' by ${listchars}
        listchars      = {
            space = ' ',                     -- space
            tab   = '> ',                    -- tab
            trail = '·',                     -- trailing space
        },
        textwidth      = 160,                --
        showtabline    = 0,                  --
        laststatus     = 0,                  --
        timeoutlen     = 200,                -- <leader> timeout
        tabstop        = 4,                  -- insert 4 spaces for a tab.
        shiftwidth     = 4,                  -- the number of spaces insertede for each indentation.
        expandtab      = true,               -- convert tabs to spaces.
        smartindent    = true,               -- smarter indenting.
        cinkeys        = ":,0#,!<Tab>",      -- cinkeys
        termguicolors  = true,               -- set term gui colors.
        cursorline     = true,               -- highlight the current line.
        writebackup    = false,              --
        signcolumn     = "yes",              -- always show the sign column.
        hlsearch       = true,               --
        incsearch      = true,               --
        clipboard      = "unnamedplus",
    },
    g = {
        fileencodings           = "UTF-8,GBK,GB2312", -- file encoding
        mapleader               = " ",
        maplocalleader          = " ",
        loaded_netrw            = 1,
        loaded_netrwPlugin      = 1,
        loaded_perl_provider    = 0,
        loaded_ruby_provider    = 0,
        loaded_python3_provider = 0,
        loaded_node_provider    = 0,
    },
    b = {
        did_ftplugin = 0,
    }
}

if vim.env.TMUX then
    options.g.clipboard = {
        name = "TmuxClipboard",
        copy = {
            ["+"] = "tmux load-buffer -w -",
            ["*"] = "tmux load-buffer -w -",
        },
        paste = {
            ["+"] = "tmux save-buffer -",
            ["*"] = "tmux save-buffer -",
        },
        cache_enabled = 1,
    }
elseif Core.wsl() then
    options.g.clipboard = {
        name = "WslClipboard",
        copy = {
            ["+"] = "clip.exe",
            ["*"] = "clip.exe",
        },
        paste = {
            ["+"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace('\r', ''))",
            ["*"] = "powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace('\r', ''))",
        },
        cache_enabled = 1,
    }
end

Core.setOptions(options)

Core.createAutoCommand("TextYankPost", nil, function()
    vim.highlight.on_yank({ higroup = "Search", timeout = 100 })
end)

Core.createAutoCommand("FileType", "go", function()
    vim.opt.formatoptions:prepend("or")
end)
