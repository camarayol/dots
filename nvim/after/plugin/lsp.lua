local function lsprename()
    if not next(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), method = 'textDocument/rename' })) then
        vim.notify('[LSP] Rename, no matching language servers with rename capability', vim.log.levels.WARN)
        return
    end

    local oldname = vim.fn.expand('<cword>')
    if oldname == '' then return end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { oldname })
    vim.api.nvim_set_option_value('filetype', 'rename', { buf = buf })
    vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'cursor',
        row = 1,
        col = 0,
        width = math.max(20, #oldname + 10),
        height = 1,
        style = 'minimal',
        border = 'rounded',
        title = ' Rename ',
        title_pos = 'center',
    })

    local function close_rename_win_buf()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
        vim.cmd('stopinsert')
    end

    core.set_keymaps {
        i = {
            ['<CR>'] = { function()
                local newname = vim.trim(vim.api.nvim_get_current_line())
                close_rename_win_buf()
                if newname ~= '' and newname ~= oldname then
                    vim.lsp.buf.rename(newname)
                end
            end, { buffer = buf } },
            ['<Esc>'] = { close_rename_win_buf, { buffer = buf } }
        },
        n = {
            ['<Esc>'] = { close_rename_win_buf, { buffer = buf } }
        }
    }

    core.create_autocommand('BufLeave', nil, { once = true, buffer = buf, callback = close_rename_win_buf })

    vim.cmd('startinsert!')
end

core.create_autocommand('LspAttach', nil, {
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local success, b = pcall(require, 'telescope.builtin')
        if success then
            core.set_mode_keymaps('n', {
                ['gr'] = { b.lsp_references, { buffer = ev.buf } },
                ['gi'] = { b.lsp_implementations, { buffer = ev.buf } },
                ['gd'] = { b.lsp_type_definitions, { buffer = ev.buf } },
                ['go'] = { b.lsp_document_symbols, { buffer = ev.buf } },
                ['gw'] = { b.lsp_dynamic_workspace_symbols, { buffer = ev.buf } },
            })
        end

        if next(vim.lsp.get_clients({ id = ev.data.client_id, bufnr = ev.buf, method = 'textDocument/documentHighlight' })) then
            local group = vim.api.nvim_create_augroup('core.lsp.dochighlight', { clear = false })
            core.create_autocommand({ 'CursorHold', 'CursorHoldI' }, nil, {
                buffer = ev.buf,
                group = group,
                callback = vim.lsp.buf.document_highlight,
            })

            core.create_autocommand({ 'CursorMoved', 'CursorMovedI' }, nil, {
                buffer = ev.buf,
                group = group,
                callback = vim.lsp.buf.clear_references,
            })

            core.create_autocommand('LspDetach', nil, function(eev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = group, buffer = eev.buf }
            end)
        end

        core.set_keymaps {
            n = {
                ['grn']   = { lsprename, { buffer = ev.buf } },
                ['K']     = { function() vim.lsp.buf.hover { border = 'rounded' } end, { buffer = ev.buf } },
                ['<M-F>'] = { function() vim.lsp.buf.format { async = true } end, { buffer = ev.buf } },
            },
            v = {
                ['<M-F>'] = { function() vim.lsp.buf.format { async = true } end, { buffer = ev.buf } }
            }
        }
    end
})

-- Don't use 'vim.schedule'. Ensure 'telescope' is loaded to guarantee proper keymap setup during 'LspAttach'
require('mini-deps').lazy(function()
    vim.lsp.enable { 'lua_ls', 'rust_analyzer', 'clangd', 'tinymist' }
end)
