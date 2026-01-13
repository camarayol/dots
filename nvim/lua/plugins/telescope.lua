return {
    source = "https://github.com/nvim-telescope/telescope.nvim",
    depends = { "https://github.com/nvim-lua/plenary.nvim" },
    config = function()
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")
        require("telescope").setup {
            defaults = {
                layout_strategy = "horizontal",
                sorting_strategy = "ascending",
                layout_config = {
                    horizontal = {
                        height = 0.9,
                        width = 0.9,
                        preview_width = 0.4,
                        prompt_position = "top",
                    }
                },
                cache_picker = {
                    num_pickers = 10,
                    limit_entries = 1000,
                    ignore_empty_prompt = true
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

        Core.setKeyMaps {
            { "n", "\\",            builtin.builtin,                   { desc = "[Telescope] builtin" } },
            { "n", "<M-\\>",        builtin.pickers,                   { desc = "[Telescope] pickers" } },
            { "n", "F",             builtin.find_files,                { desc = "[Telescope] find_files" } },
            { "n", "B",             builtin.buffers,                   { desc = "[Telescope] buffers" } },
            { "n", "<C-f>",         builtin.current_buffer_fuzzy_find, { desc = "[Telescope] current_buffer_fuzzy_find" } },
            { "n", "<leader><C-f>", builtin.live_grep,                 { desc = "[Telescope] live_grep" } },
        }
    end
}
