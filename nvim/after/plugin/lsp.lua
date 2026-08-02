local group = vim.api.nvim_create_augroup('core.LspDocumentHighlight', { clear = false })

local LspAttach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    core.set_keymaps {
        {
            modes = 'n', lhs = 'K',
            rhs = vim.lsp.buf.hover,
            opts = { desc = 'vim.lsp.buf.hover' }
        },
        {
            modes = { 'n', 'v' }, lhs = '<M-F>',
            rhs = function() vim.lsp.buf.format { async = true } end,
            opts = { desc = 'vim.lsp.buf.format' }
        },
        {
            modes = 'n', lhs = 'grd',
            rhs = vim.diagnostic.open_float,
            opts = { desc = 'vim.diagnostic.open_float' }
        },
        {
            modes = 'n', lhs = 'grn',
            rhs = function()
                if not next(vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf(), method = 'textDocument/rename' })
                then
                    return vim.notify('no matching language servers with rename capability', vim.log.levels.WARN)
                end

                local newname = ''
                local oldname = vim.fn.expand('<cword>')
                if oldname == '' then return end

                core.create_once_cursor_window {
                    winopts = { title = 'Rename', title_pos = 'center' },
                    on_open = function()
                        vim.api.nvim_set_current_line(oldname)
                        vim.cmd('startinsert!')
                    end,
                    on_exec = function()
                        newname = vim.trim(vim.api.nvim_get_current_line())
                    end,
                    on_exit = function()
                        if newname ~= oldname then vim.lsp.buf.rename(newname) end
                        vim.cmd('stopinsert')
                    end
                }
            end,
            opts = { desc = 'vim.lsp.buf.rename' }
        }
    }

    core.set_keymaps {
        {
            modes = 'n', lhs = 'grr', rhs = '<Cmd>FzfLua lsp_references<CR>',
            { buf = ev.buf, desc = 'FzfLua lsp_references' }
        },
        {
            modes = 'n', lhs = 'gri', rhs = '<Cmd>FzfLua lsp_implementations<CR>',
            { buf = ev.buf, desc = 'FzfLua lsp_implementations' }
        },
        {
            modes = 'n', lhs = 'grt', rhs = '<Cmd>FzfLua lsp_typedefs<CR>',
            { buf = ev.buf, desc = 'FzfLua lsp_typedefs' }
        },
        {
            modes = 'n', lhs = 'gd', rhs = '<Cmd>FzfLua lsp_definitions<CR>',
            { buf = ev.buf, desc = 'FzfLua lsp_definitions' }
        },
        {
            modes = 'n', lhs = 'go', rhs = '<Cmd>FzfLua lsp_document_symbols<CR>',
            { buf = ev.buf, desc = 'FzfLua lsp_document_symbols' }
        },
        {
            modes = 'n', lhs = 'gw', rhs = '<Cmd>FzfLua lsp_workspace_symbols<CR>',
            { buf = ev.buf, desc = 'FzfLua lsp_workspace_symbols' }
        },
    }

    if next(vim.lsp.get_clients { id = ev.data.client_id, bufnr = ev.buf, method = 'textDocument/documentHighlight' })
    then
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = ev.buf, group = group, callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = ev.buf, group = group, callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
            callback = function(e)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = group, buffer = e.buf }
            end
        })
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('core.LspAttach', { clear = true }),
    callback = LspAttach
})

vim.schedule(function()
    vim.lsp.enable { 'lua_ls', 'rust_analyzer', 'clangd', 'tinymist', 'gdscript' }
end)
