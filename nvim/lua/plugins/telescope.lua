return {
    source = 'https://github.com/nvim-telescope/telescope.nvim',
    depends = { 'https://github.com/nvim-lua/plenary.nvim' },
    config = function()
        local builtin = require('telescope.builtin')
        local actions = require('telescope.actions')

        Core.setKeyMaps {
            n = {
                ['\\']            = builtin.builtin,
                ['<C-\\>']        = builtin.pickers,
                ['F']             = builtin.find_files,
                ['B']             = builtin.buffers,
                ['<C-f>']         = builtin.current_buffer_fuzzy_find,
                ['<Leader><C-f>'] = builtin.live_grep,
            }
        }

        require('telescope').setup {
            defaults = {
                preview = false,
                layout_strategy = 'horizontal',
                sorting_strategy = 'ascending',
                layout_config = {
                    horizontal = { prompt_position = 'top', height = 0.6, width = 0.6 }
                },
                cache_picker = {
                    num_pickers = 10,
                    limit_entries = 1000,
                    ignore_empty_prompt = true
                },
                default_mappings = {
                    n = {
                        ['<Esc>']      = actions.close,
                        ['<CR>']       = actions.select_default,
                        ['j']          = actions.move_selection_next,
                        ['k']          = actions.move_selection_previous,
                        ['<PageUp>']   = actions.preview_scrolling_up,
                        ['<PageDown>'] = actions.preview_scrolling_down,
                    },
                    i = {
                        ['<Esc>']      = actions.close,
                        ['<CR>']       = actions.select_default,
                        ['<M-j>']      = actions.move_selection_next,
                        ['<M-k>']      = actions.move_selection_previous,
                        ['<PageUp>']   = actions.preview_scrolling_up,
                        ['<PageDown>'] = actions.preview_scrolling_down,
                    }
                }
            },
            pickers = {
                keymaps = { layout_config = { horizontal = { height = 0.9, width = 0.9 } } },
                commands = { layout_config = { horizontal = { height = 0.9, width = 0.9 } } },
                live_grep = {
                    preview       = true,
                    path_display  = { 'filename_first' },
                    layout_config = { horizontal = { height = 0.9, width = 0.9, preview_width = 0.6 } }
                },
                highlights = {
                    preview = true,
                    layout_config = { horizontal = { height = 0.8, width = 0.8, preview_width = 0.6 } }
                },
                buffers = { path_display = { 'filename_first' } },
            }
        }
    end
}
