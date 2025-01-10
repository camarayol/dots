local lspconfig = function()
    local lspconfig = require("lspconfig")

    -- gopls
    lspconfig.gopls.setup {
        settings = {
            gopls = {
                gofumpt = true,
                usePlaceholders = true,
                completeUnimported = true,
            }
        }
    }

    -- clangd
    lspconfig.clangd.setup {
        cmd = { "clangd", "--clang-tidy" },
        init_options = {
            clangdFileStatus = true,
            usePlaceholders = true,
            completeUnimported = true,
            semanticHighlighting = false,
            snippetSupport = false,
        },
        settings = {}
    }

    -- rust-analyzer
    -- https://www.andersevenrud.net/neovim.github.io/lsp/configurations/rust_analyzer/
    lspconfig.rust_analyzer.setup {
        root_dir = function(fname)
            local util = require("lspconfig.util")
            local cargo_crate_dir = util.root_pattern 'Cargo.toml' (fname)
            local cmd = 'cargo metadata --no-deps --format-version 1'
            if cargo_crate_dir ~= nil then
                cmd = cmd .. ' --manifest-path ' .. util.path.join(cargo_crate_dir, 'Cargo.toml')
            end
            local cargo_metadata = vim.fn.system(cmd)
            local cargo_workspace_dir = nil
            if vim.v.shell_error == 0 then
                cargo_workspace_dir = vim.fn.json_decode(cargo_metadata)['workspace_root']
            end
            return cargo_workspace_dir
                or cargo_crate_dir
                or util.root_pattern 'rust-project.json' (fname)
                or util.find_git_ancestor(fname)
        end,
        -- root_dir = require("lspconfig/util").root_pattern("Cargo.toml"),
        settings = {
            ["rust-analyzer"] = {
                cargo       = { allFeatures = true },
                procMacro   = { enable = true },
                diagnostic  = { enable = true },
                checkOnSave = { enable = true },
                inlayHints  = {
                    typeHints = true,
                    parameterHints = true
                },
                completion  = {
                    autoimport = { enable = false }
                }
            }
        }
    }

    -- lua-language-server
    lspconfig.lua_ls.setup {
        settings = {
            Lua = {
                semantic = { enable = false },
                runtime = { version = "LuaJIT" },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        '~/.luarocks/share/lua/5.4/'
                    }
                }
            }
        }
    }

    -- jsonls
    lspconfig.jsonls.setup {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json" },
        init_options = { provideFormatter = true },
        single_file_support = true
    }

    -- cmake-language-server
    lspconfig.cmake.setup {}

    -- bash-language-server
    lspconfig.bashls.setup {}
end

return {
    source = "https://github.com/neovim/nvim-lspconfig",
    depends = { "https://github.com/williamboman/mason.nvim" },
    checkout = "v1.2.0",
    config = function()
        Core.setHighlights {
            ["DiagnosticError"]          = { fg = C.DRed },
            ["DiagnosticUnderlineWarn"]  = { fg = C.Yellow, ui = S.Underline },
            ["DiagnosticUnderlineError"] = { fg = C.DRed,   ui = S.Underline },
        }

        Core.linkHighlights {
            ["LspInlayHint"] = "Comment",
        }

        Core.createAutoCommand("FileType", "qf", function ()
            local bn = vim.fn.bufnr("%")
            local OpenAndCloseQF = string.format("<CR><Cmd>%dbdelete<CR>", bn)
            Core.setKeyMaps {
                { "n", "<CR>", OpenAndCloseQF, { buffer = bn } },
                { "n",  "o",   OpenAndCloseQF, { buffer = bn } },
                { "n",  "j",   "j<CR><C-w>j",  { buffer = bn } },
                { "n",  "k",   "k<CR><C-w>j",  { buffer = bn } },
            }
        end)

        -- Core.setKeyMaps {
        --     {
        --         "n", "<leader>le", vim.diagnostic.open_float,
        --         { desc = "LSP: Show diagnostics in a floating window" }
        --     },
        --     {
        --         "n", "<leader>ln", vim.diagnostic.goto_next,
        --         { desc = "LSP: Move to the next diagnostic" }
        --     },
        --     {
        --         "n", "<leader>lp", vim.diagnostic.goto_prev,
        --         { desc = "LSP: Move to the prev diagnostic" }
        --     },
        --     {
        --         "n", "<leader>ll", vim.diagnostic.setloclist,
        --         { desc = "LSP: Add buffer diagnostics to the location list" }
        --     },
        -- }

        Core.createAutoCommand("LspAttach", nil, function(ev)
            -- local client = vim.lsp.get_client_by_id(ev.data.client_id)
            -- if client and client.server_capabilities.inlayHintProvider then
            --     vim.lsp.inlay_hint.enable(true)
            -- end

            vim.lsp.inlay_hint.enable(true)
            vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

            Core.setKeyMaps {
                -- {
                --     "n", "gd", vim.lsp.buf.definition,
                --     { buffer = ev.buf, desc = "LSP: Jumps to the definition" }
                -- },
                -- {
                --     "n", "gD", vim.lsp.buf.declaration,
                --     { buffer = ev.buf, desc = "LSP: Jumps to the declaration" }
                -- },
                -- {
                --     "n", "gr", vim.lsp.buf.references,
                --     { buffer = ev.buf, desc = "LSP: List all the references" }
                -- },
                -- {
                --     { "n", "v" }, "<leader>la", vim.lsp.buf.code_action,
                --     { buffer = ev.buf, desc = "LSP: Code Action" }
                -- },
                -- {
                --     "n", "<leader>rn", vim.lsp.buf.rename,
                --     { buffer = ev.buf, desc = "LSP: Renames all references" }
                -- },
                {
                    { "n", "v" }, "<M-F>", function() vim.lsp.buf.format { async = true } end,
                    { buffer = ev.buf, desc = "LSP: Formats a buffer" }
                }
            }
        end)
        vim.defer_fn(lspconfig, 2)
    end
}
