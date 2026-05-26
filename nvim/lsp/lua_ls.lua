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
                globals = {
                    's', 'c', 't', 'i', 'd', 'sn', 'fmt', 'extras' -- luasnip
                }
            }
        }
    }
}
