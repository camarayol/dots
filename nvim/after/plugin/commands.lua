-- highlight yank text
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('core.TextYankPost', { clear = true }),
    callback = function()
        vim.hl.on_yank { higroup = 'Search', timeout = 100 }
    end
})

-- linux fcitx5-remote
if core.hasfeature('linux') and not core.hasfeature('wsl') and vim.fn.executable('fcitx5-remote') then
    vim.api.nvim_create_autocmd('InsertLeave', {
        once = true,
        group = vim.api.nvim_create_augroup('core.FcitxRemote', { clear = true }),
        callback = function()
            if tonumber(vim.fn.system('fcitx5-remote')) == 2 then
                vim.fn.system('fcitx5-remote -c')
            end
        end
    })
end

-- windows weasel
if core.hasfeature('win32') then
    vim.api.nvim_create_autocmd('InsertLeave', {
        once = true,
        group = vim.api.nvim_create_augroup('core.WeaselServer', { clear = true }),
        callback = function()
            vim.fn.system('WeaselServer.exe /ascii')
        end
    })
end

-- core.create_autocommand('FileType', function(ev)
--     if vim.bo[ev.buf].buftype ~= '' then return end
--     if ev.match == 'sagarename' then return end
--
--     -- Missing parsers are expected for some filetypes, so leave them on Vim's
--     -- regular syntax highlighting without reporting an error.
--     pcall(vim.treesitter.start, ev.buf)
-- end)

-- auto delete empty buffer after BufLeave
vim.api.nvim_create_autocmd('BufLeave', {
    group = vim.api.nvim_create_augroup('core.BufLeaveAutoDelete', { clear = true }),
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
                -- delete empty buffer
                vim.api.nvim_buf_delete(ev.buf, { force = true })

                -- delete this autocommands
                vim.api.nvim_del_autocmd(ev.id)
            end
        end)
    end
})

-- yaml
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'yaml',
    callback = function()
        vim.bo.shiftwidth = 2
    end
})

-- gitcommit
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gitcommit',
    callback = function()
        vim.bo.textwidth = 200
    end
})

-- core.create_autocommand('FileType', 'qf', function(ev)
--     core.set_mode_keymaps('n', {
--         ['<CR>'] = { string.format('<CR><Cmd>%dbdelete<CR>', ev.buf), { buffer = ev.buf } },
--         ['o']    = { string.format('<CR><Cmd>%dbdelete<CR>', ev.buf), { buffer = ev.buf } },
--         ['j']    = { 'j<CR><C-w>j', { buffer = ev.buf } },
--         ['k']    = { 'k<CR><C-w>j', { buffer = ev.buf } },
--     })
-- end)

-- get current treesitter status
vim.api.nvim_create_user_command('CoreTreesitter', function()
    local filetype = vim.bo.filetype
    local treesitter = vim.treesitter.language.get_lang(filetype) or ''
    local exist, error = vim.treesitter.language.add(treesitter)
    vim.notify(string.format('CoreTreesitter: %s %s', treesitter, exist or tostring(error)))
end, { desc = 'Get current treesitter status' })

-- redir command output
vim.api.nvim_create_user_command('CoreRedir', function(args)
    local result = vim.api.nvim_exec2(args.args, { output = true })
    vim.cmd('enew')

    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result.output, '\n', { trimempty = false }))

    vim.bo[buf].filetype  = 'vim'
    vim.bo[buf].buftype   = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile  = false
end, { nargs = '+', complete = 'command', desc = 'Redir command output' })
