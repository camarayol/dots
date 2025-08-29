return {
    source = "https://github.com/nvim-treesitter/nvim-treesitter",
    hooks = { post_install = function() vim.cmd("TSUpdate") end },
    config = function()
        require("nvim-treesitter.configs").setup {
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-CR>"
                }
            }
        }
        vim.treesitter.language.register("json5", "json")

        MiniDeps.later_add {
            source = "https://github.com/nvim-treesitter/playground",
            config = function()
                Core.setKeyMaps { { "n", "<F2>", "<Cmd>TSHighlightCapturesUnderCursor<CR>" } }
            end
        }
    end
}
