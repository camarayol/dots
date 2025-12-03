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
        swapfile       = false,
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

Core.setOptions(options)

Core.setCommentStrings {
    { cs = "# %s",     pattern = { "ini" } },
    { cs = "/* %s */", pattern = { "css" } },
    { cs = "// %s",    pattern = { "cpp", "rust", "kdl", "rasi", "jsonc" } },
}

Core.createAutoCommand("TextYankPost", nil, function()
    vim.highlight.on_yank({ higroup = "Search", timeout = 100 })
end)

-- if vim.fn.executable("fcitx5-remote") then
--     Core.createAutoCommand("InsertLeave", "*", function()
--         if tonumber(vim.fn.system("fcitx5-remote")) == 2 then
--             vim.fn.system("fcitx5-remote -c")
--         end
--     end)
-- end

Core.createAutoCommand("FileType", "go", function()
    vim.opt.formatoptions:prepend("or")
end)

Core.createAutoCommand("FileType", "yaml", function()
    vim.bo.shiftwidth = 2
end)
