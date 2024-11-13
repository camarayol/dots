return {
    source = "https://github.com/nvim-telescope/telescope.nvim",
    depends = { "https://github.com/nvim-lua/plenary.nvim" },
    config = function()
        local telescope = function(cmd) return string.format("<Cmd>Telescope %s<CR>", cmd) end
        Core.setKeyMaps {
            { "n", "\\",            telescope("builtin"),                   { desc = "[Telescope] builtin"    } },
            { "n", "F",             telescope("find_files"),                { desc = "[Telescope] find_files" } },
            { "n", "B",             telescope("buffers"),                   { desc = "[Telescope] buffers"    } },
            { "n", "<C-f>",         telescope("current_buffer_fuzzy_find"), { desc = "[Telescope] buffers"    } },
            { "n", "<leader><C-f>", telescope("live_grep"),                 { desc = "[Telescope] buffers"    } },

        }
        local actions = require("telescope.actions")
        require("telescope").setup {
            defaults = {
                layout_strategy = 'horizontal',
                sorting_strategy = "ascending",
                layout_config = {
                    horizontal = {
                        height = 0.9,
                        width = 0.8,
                        preview_width = 0.6,
                        prompt_position = "top",
                    }
                },
                default_mappings = {
                    n = {
                        ["<Esc>"]      = actions.close,
                        ["<CR>"]       = actions.select_default,
                        ["<Down>"]     = actions.move_selection_next,
                        ["j"]          = actions.move_selection_next,
                        ["<Up>"]       = actions.move_selection_previous,
                        ["k"]          = actions.move_selection_previous,
                        ["<PageUp>"]   = actions.preview_scrolling_up,
                        ["<PageDown>"] = actions.preview_scrolling_down,
                    },
                    i = {
                        ["<Esc>"]      = actions.close,
                        ["<CR>"]       = actions.select_default,
                        ["<Down>"]     = actions.move_selection_next,
                        ["<M-j>"]      = actions.move_selection_next,
                        ["<Up>"]       = actions.move_selection_previous,
                        ["<M-k>"]      = actions.move_selection_previous,
                        ["<PageUp>"]   = actions.preview_scrolling_up,
                        ["<PageDown>"] = actions.preview_scrolling_down,
                    }
                }
            }
        }
    end
}
