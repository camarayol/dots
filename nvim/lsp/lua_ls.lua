return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.git' },
    settings = {
        Lua = {
            semantic = { enable = false },
            runtime = { version = 'LuaJIT' },
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                }
            },
            diagnostics = {
                disable = { 'lowercase-global', 'unused-local' },
                globals = {
                    's', 'c', 't', 'i', 'd', 'sn', 'fmt', 'extras' -- luasnip
                },
            }
        }
    },
    on_attach = function(client, bufnr)
        vim.lsp.document_color.enable(true, { 'lua_ls' }, { style = 'foreground' })
    end
}
