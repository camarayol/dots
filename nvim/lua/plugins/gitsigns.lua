return {
    source = "https://github.com/lewis6991/gitsigns.nvim",
    config = function()
        Core.setHighlights {
            ["Added"]   = { fg = C.DGreen, bg = C.None },
            ["Changed"] = { fg = C.Orange, bg = C.None },
            ["Removed"] = { fg = C.Red,    bg = C.None },
        }
        Core.linkHighlights {
            ["DiffAdd"]    = "Added",
            ["DiffChange"] = "Changed",
            ["DiffDelete"] = "Removed",
            ["GitSignsCurrentLineBlame"] = "Comment",
        }
        Core.setKeyMaps {
            { "n",     "[",      "<Cmd>Gitsigns prev_hunk<CR>",    { desc = "[Git] prev_hunk"    } },
            { "n",     "]",      "<Cmd>Gitsigns next_hunk<CR>",    { desc = "[Git] next_hunk"    } },
            { "n", "<leader>gr", "<Cmd>Gitsigns reset_hunk<CR>",   { desc = "[Git] reset_hunk"   } },
            { "n", "<leader>gv", "<Cmd>Gitsigns preview_hunk<CR>", { desc = "[Git] preview_hunk" } },
        }
        require("gitsigns").setup {
            signs                        = {
                add          = { text = "▌" },
                change       = { text = "▌" },
                delete       = { text = "▌" },
                topdelete    = { text = "▌" },
                changedelete = { text = "▌" },
                untracked    = { text = "▌" },
            },
            signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
            numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
            linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir                 = { interval = 1000, follow_files = true },
            attach_to_untracked          = true,
            current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts      = { virt_text = true, virt_text_pos = "eol", delay = 100, ignore_whitespace = false, },
            current_line_blame_formatter = "    <author> <committer_time:%R>: <summary>",
            sign_priority                = 6,
            update_debounce              = 100,
            status_formatter             = nil,   -- Use default
            max_file_length              = 40000, -- Disable if file is longer than this (in lines)
            preview_config               = { border = "rounded", style = "minimal", relative = "cursor", row = 0, col = 1 },
        }
    end
}
