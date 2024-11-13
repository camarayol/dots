return {
    source = "https://github.com/williamboman/mason.nvim",
    config = function()
        require("mason").setup {
            ui = { border = "single" },
            github = { download_url_template = "https://github.com/%s/releases/download/%s/%s" }
        }
        -- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
        local mason_servers = {
            -- "gopls",
            "clangd",
            -- "json-lsp",
            "rust-analyzer",
            "lua-language-server",
            -- "cmake-language-server",
        }
        for _, lsp in ipairs(mason_servers) do
            if not require("mason-registry").is_installed(lsp) then
                vim.api.nvim_command("MasonInstall " .. lsp)
            end
        end
    end
}
