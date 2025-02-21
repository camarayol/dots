local Core = require("core")

local options = {
    opt = {
        fileencodings  = "UTF-8,GBK,GB2312",
        mouse          = "a",
        number         = true,
        relativenumber = true,
        showmode       = false,
        sidescrolloff  = 8,
        list           = true, -- :h listchars
        listchars      = {
            space = ' ',
            tab   = '> ',
            trail = '·',
        },
        textwidth      = 160,
        showtabline    = 0,
        laststatus     = 0,
        timeoutlen     = 200,
        tabstop        = 4,
        shiftwidth     = 4,
        expandtab      = true,
        smartindent    = true,
        cinkeys        = ":,0#,!<Tab>", -- :h cinkeys-format
        termguicolors  = true,
        cursorline     = true,
        writebackup    = false,
        signcolumn     = "yes",
        hlsearch       = true,
        incsearch      = true,
        clipboard      = "unnamedplus",
        -- commentstring  = '# %s' -- default commentstring
    },
    g = {
        fileencodings           = "UTF-8,GBK,GB2312",
        mapleader               = " ",
        maplocalleader          = " ",
        loaded_netrw            = 1,
        loaded_netrwPlugin      = 1,
        loaded_perl_provider    = 0,
        loaded_ruby_provider    = 0,
        loaded_python3_provider = 0,
        loaded_node_provider    = 0,
    },
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

-- highlight copy content
Core.createAutoCommand("TextYankPost", nil, function()
    vim.highlight.on_yank({ higroup = "Search", timeout = 100 })
end)

Core.createAutoCommand("FileType", "go", function()
    vim.opt.formatoptions:prepend("or")
end)

Core.createAutoCommand("FileType", "yaml", function()
    vim.bo.shiftwidth = 2
end)

Core.createAutoCommand("InsertLeave", "*", function()
    if tonumber(vim.fn.system("fcitx5-remote")) == 2 then
        vim.fn.system("fcitx5-remote -c")
    end
end)
