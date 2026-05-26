core.create_autocommand('LspAttach', {
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        core.set_keymaps('n', {
            ['K'] = { buf = ev.buf, callback = vim.lsp.buf.hover },
        })
        core.set_keymaps({ 'n', 'v' }, {
            ['<M-F>'] = { buf = ev.buf, callback = function() vim.lsp.buf.format { async = true } end }
        })

        core.set_keymaps('n', {
            ['grn'] = {
                desc = 'vim.lsp.buf.rename',
                callback = function()
                    if not next(vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf(), method = 'textDocument/rename' })
                    then
                        return vim.notify('[LSP] no matching language servers with rename capability',
                            vim.log.levels.WARN)
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
                end
            }
        })

        local suc, tb = pcall(require, 'telescope.builtin')
        if suc then
            core.set_keymaps('n', {
                ['grr'] = {
                    buf = ev.buf,
                    desc = '[Telescope] lsp_references',
                    callback = tb.lsp_references,
                },
                ['gri'] = {
                    buf = ev.buf,
                    desc = '[Telescope] lsp_implementations',
                    callback = tb.lsp_implementations,
                },
                ['grt'] = {
                    buf = ev.buf,
                    desc = '[Telescope] lsp_type_definitions',
                    callback = tb.lsp_type_definitions,
                },
                ['gd']  = {
                    buf = ev.buf,
                    desc = '[Telescope] lsp_definitions',
                    callback = tb.lsp_definitions,
                },
                ['go']  = {
                    buf = ev.buf,
                    desc = '[Telescope] lsp_document_symbols',
                    callback = tb.lsp_document_symbols,
                },
                ['gw']  = {
                    buf = ev.buf,
                    desc = '[Telescope] lsp_dynamic_workspace_symbols',
                    callback = tb.lsp_dynamic_workspace_symbols,
                },
            })
        end

        if next(vim.lsp.get_clients { id = ev.data.client_id, bufnr = ev.buf, method = 'textDocument/documentHighlight' })
        then
            local group = vim.api.nvim_create_augroup('core.lsp.document.highlight', { clear = false })

            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = ev.buf, group = group, callback = vim.lsp.buf.document_highlight,
            })

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
})

vim.schedule(function()
    vim.lsp.enable { 'lua_ls', 'rust_analyzer', 'clangd', 'tinymist' }
end)
