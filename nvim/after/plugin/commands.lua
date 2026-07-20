core.create_autocommand('TextYankPost', function()
    vim.hl.on_yank { higroup = 'Search', timeout = 100 }
end)

if core.hasfeature('linux') and not core.hasfeature('wsl') and vim.fn.executable('fcitx5-remote') then
    core.create_autocommand('InsertLeave', function()
        if tonumber(vim.fn.system('fcitx5-remote')) == 2 then
            vim.fn.system('fcitx5-remote -c')
        end
    end)
end

if core.hasfeature('win32') then
    core.create_autocommand('InsertLeave', function()
        vim.fn.system('WeaselServer.exe /ascii')
    end)
end

core.create_autocommand('FileType', function(ev)
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

local cleanup_noname_buffer = vim.api.nvim_create_augroup('core.cleanup.noname.buffer', { clear = true })
core.create_autocommand('BufLeave', {
    group = cleanup_noname_buffer,
    callback = function(ev)
        if vim.api.nvim_buf_get_name(ev.buf) ~= '' then return end
        if vim.bo[ev.buf].buftype ~= '' then return end
        if vim.bo[ev.buf].modified then return end

        vim.schedule(function()
            local buf = vim.api.nvim_get_current_buf()
            local buftype = vim.bo[buf].buftype

            if vim.api.nvim_buf_is_valid(buf) and
                vim.tbl_contains({ 'terminal', 'nofile', 'prompt' }, buftype) then
                return
            end

            if vim.api.nvim_buf_is_valid(ev.buf) then
                vim.api.nvim_buf_delete(ev.buf, { force = true })
                for _, opts in pairs(vim.api.nvim_get_autocmds { group = cleanup_noname_buffer, event = 'BufLeave' }) do
                    vim.api.nvim_del_autocmd(opts.id)
                end
            end
        end)
    end
})

core.create_autocommand('FileType', { pattern = 'yaml', callback = function() vim.bo.shiftwidth = 2 end })

core.create_autocommand('FileType', { pattern = 'gitcommit', callback = function() vim.bo.textwidth = 200 end })

-- core.create_autocommand('FileType', 'qf', function(ev)
--     core.set_mode_keymaps('n', {
--         ['<CR>'] = { string.format('<CR><Cmd>%dbdelete<CR>', ev.buf), { buffer = ev.buf } },
--         ['o']    = { string.format('<CR><Cmd>%dbdelete<CR>', ev.buf), { buffer = ev.buf } },
--         ['j']    = { 'j<CR><C-w>j', { buffer = ev.buf } },
--         ['k']    = { 'k<CR><C-w>j', { buffer = ev.buf } },
--     })
-- end)

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
