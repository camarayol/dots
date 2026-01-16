-- highlight yank text
Core.createAutoCommand('TextYankPost', '*', function()
    vim.highlight.on_yank({ higroup = 'Search', timeout = 100 })
end)

-- linux fctix5
if Core.osSysname('Linux') and vim.fn.executable('fcitx5-remote') then
    Core.createAutoCommand('InsertLeave', '*', function()
        if tonumber(vim.fn.system('fcitx5-remote')) == 2 then
            vim.fn.system('fcitx5-remote -c')
        end
    end)
end

Core.createAutoCommand('FileType', 'go', function()
    vim.opt.formatoptions:prepend('or')
end)

Core.createAutoCommand('FileType', 'yaml', function()
    vim.bo.shiftwidth = 2
end)

Core.createAutoCommand('FileType', 'gitcommit', function()
    vim.bo.textwidth = 200
end)

Core.createAutoCommand('FileType', 'quickfix', function(args)
    Core.setKeyMaps2 {
        n = {
            ['<CR>'] = { string.format('<CR><Cmd>%dbdelete<CR>', args.buf), { buffer = args.buf } },
            ['o']    = { string.format('<CR><Cmd>%dbdelete<CR>', args.buf), { buffer = args.buf } },
            ['j']    = { 'j<CR><C-w>j', { buffer = args.buf } },
            ['k']    = { 'k<CR><C-w>j', { buffer = args.buf } },
        }
    }
end)

-- treesitter
Core.createAutoCommand('FileType', '*', function(args)
    if vim.bo[args.buf].buftype ~= '' then return end
    if args.match == 'sagarename' then return end

    local treesitter = vim.treesitter.language.get_lang(args.match) or ''
    if vim.treesitter.language.add(treesitter) then
        vim.treesitter.start(args.buf, treesitter)
    else
        vim.cmd('TSInstall ' .. treesitter)
        -- TODO: automatic start treesitter after installed
    end
end)

Core.createUserCommand('TSParserStatus', function()
    local filetype = vim.bo.filetype
    local treesitter = vim.treesitter.language.get_lang(filetype) or ''
    local exist, error = vim.treesitter.language.add(treesitter)
    vim.notify(string.format('TSGetParser: %s %s', treesitter, exist or tostring(error)))
end)

-- lsp
Core.createAutoCommand('LspAttach', '*', function(args)
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    Core.setKeyMaps2 {
        [{ 'n', 'v' }] = {
            ['<M-F>'] = { function() vim.lsp.buf.format { async = true } end,
                { buffer = args.buf, desc = '[LSP] format' } }
        }
    }
end)
