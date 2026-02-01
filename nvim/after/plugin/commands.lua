core.create_autocommand('TextYankPost', '*', function()
    vim.highlight.on_yank { higroup = 'Search', timeout = 100 }
end)

-- Automatic switch 'fcitx5-remote'
if vim.fn.has('linux') and vim.fn.executable('fcitx5-remote') then
    core.create_autocommand('InsertLeave', '*', function()
        if tonumber(vim.fn.system('fcitx5-remote')) == 2 then
            vim.fn.system('fcitx5-remote -c')
        end
    end)
end

-- Automatic install 'treesitter'
core.create_autocommand('FileType', '*', function(ev)
    if vim.bo[ev.buf].buftype ~= '' then return end
    if ev.match == 'sagarename' then return end

    local treesitter = vim.treesitter.language.get_lang(ev.match) or ''
    if vim.treesitter.language.add(treesitter) then
        vim.treesitter.start(ev.buf, treesitter)
    else
        if vim.api.nvim_get_commands({ builtin = false })['TSInstall'] ~= nil then
            vim.cmd('TSInstall ' .. treesitter)
            -- TODO: automatic start treesitter after installed
        end
    end
end)

core.create_autocommand('FileType', 'yaml', function()
    vim.bo.shiftwidth = 2
end)

core.create_autocommand('FileType', 'gitcommit', function()
    vim.bo.textwidth = 200
end)

core.create_autocommand('FileType', 'qf', function(ev)
    core.set_mode_keymaps('n', {
        ['<CR>'] = { string.format('<CR><Cmd>%dbdelete<CR>', ev.buf), { buffer = ev.buf } },
        ['o']    = { string.format('<CR><Cmd>%dbdelete<CR>', ev.buf), { buffer = ev.buf } },
        ['j']    = { 'j<CR><C-w>j', { buffer = ev.buf } },
        ['k']    = { 'k<CR><C-w>j', { buffer = ev.buf } },
    })
end)

core.create_usercommand('CoreTreesitter', function()
    local filetype = vim.bo.filetype
    local treesitter = vim.treesitter.language.get_lang(filetype) or ''
    local exist, error = vim.treesitter.language.add(treesitter)
    vim.notify(string.format('CoreTreesitter: %s %s', treesitter, exist or tostring(error)))
end, {})

core.create_usercommand('CoreRedir', function(args)
    local result = vim.api.nvim_exec2(args.args, { output = true })
    vim.cmd('enew')

    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result.output, '\n', { trimempty = false }))

    vim.bo[buf].filetype = 'vim'
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
end, { nargs = '+', complete = 'command' })
