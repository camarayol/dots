local function lsprename()
    if not next(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf(), method = 'textDocument/rename' })) then
        vim.notify('[LSP] Rename, no matching language servers with rename capability', vim.log.levels.WARN)
        return
    end

    local newname = ''
    local oldname = vim.fn.expand('<cword>')
    if oldname == '' then return end

    core.create_once_cursor_window {
        winopts = {
            width = math.max(20, #oldname + 10),
            title = 'LSP Rename',
            title_pos = 'center'
        },
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

core.create_autocommand('LspAttach', nil, {
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        local success, b = pcall(require, 'telescope.builtin')
        if success then
            core.set_mode_keymaps('n', {
                ['gr'] = { b.lsp_references, { buffer = ev.buf } },
                ['gi'] = { b.lsp_implementations, { buffer = ev.buf } },
                ['gt'] = { b.lsp_type_definitions, { buffer = ev.buf } },
                ['gd'] = { b.lsp_definitions, { buffer = ev.buf } },
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
