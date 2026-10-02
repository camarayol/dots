local group = vim.api.nvim_create_augroup('core.LspDocumentHighlight', { clear = false })

local LspAttach = function(ev)
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    core.sk('n', 'K', vim.lsp.buf.hover, { desc = 'vim.lsp.buf.hover' })
    core.sk('n', 'grn', vim.lsp.buf.rename, { desc = 'vim.lsp.buf.rename' })
    core.sk('n', 'grd', vim.diagnostic.open_float, { desc = 'vim.diagnostic.open_float' })
    core.sk('n', '<M-F>', function() vim.lsp.buf.format { async = true } end, { desc = 'vim.lsp.buf.format' })
    core.sk('v', '<M-F>', function() vim.lsp.buf.format { async = true } end, { desc = 'vim.lsp.buf.format' })

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
