local M = {
    source = 'https://github.com/nvim-telescope/telescope.nvim',
}

M.depends = {
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope-live-grep-args.nvim',
    {
        source = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
        hooks = function(ev)
            vim.notify('[telescope-fzf-native] building ...')
            vim.system({ 'make' }, { cwd = ev.path }, vim.schedule_wrap(function(out)
                if out.code == 0 then
                    vim.notify('[telescope-fzf-native] build success!')
                else
                    vim.notify('[telescope-fzf-native] build failed! ' .. out.stderr, vim.log.levels.WARN)
                end
            end))
        end
    }
}

M.config = function()
    local b = require('telescope.builtin')
    local a = require('telescope.actions')

    core.set_mode_keymaps('n', {
        ['\\']            = b.builtin,
        ['<C-\\>']        = b.pickers,
        ['F']             = b.find_files,
        ['B']             = b.buffers,
        ['<C-f>']         = b.current_buffer_fuzzy_find,
        ['<Leader><C-f>'] = b.live_grep,
    })

    require('telescope').setup {
        defaults = {
            preview = false,
            dynamic_preview_title = true,
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
                    ['<Esc>']      = a.close,
                    ['<CR>']       = a.select_default,
                    ['j']          = a.move_selection_next,
                    ['k']          = a.move_selection_previous,
                    ['<C-q>']      = a.smart_send_to_qflist + a.open_qflist,
                    ['<PageUp>']   = a.preview_scrolling_up,
                    ['<PageDown>'] = a.preview_scrolling_down,
                },
                i = {
                    ['<Esc>']      = a.close,
                    ['<CR>']       = a.select_default,
                    ['<M-j>']      = a.move_selection_next,
                    ['<M-k>']      = a.move_selection_previous,
                    ['<C-q>']      = a.smart_send_to_qflist + a.open_qflist,
                    ['<PageUp>']   = a.preview_scrolling_up,
                    ['<PageDown>'] = a.preview_scrolling_down,
                }
            }
        },
        pickers = {
            keymaps = { layout_config = { horizontal = { height = 0.9, width = 0.9 } } },
            commands = { layout_config = { horizontal = { height = 0.9, width = 0.9 } } },
            live_grep = {
                theme = 'ivy',
                preview = true,
                path_display = { 'tail' },
                layout_config = { horizontal = { preview_width = 0.6 } }
            },
            current_buffer_fuzzy_find = {
                layout_config = {
                    width = { padding = 0.1 },
                    height = { padding = 0.1 },
                }
            },
            lsp_definitions = {
                theme = 'ivy',
                preview = true,
                path_display = { 'tail' },
                layout_config = { horizontal = { preview_width = 0.6 } }
            },
            lsp_type_definitions = {
                theme = 'ivy',
                preview = true,
                path_display = { 'tail' },
                layout_config = { horizontal = { preview_width = 0.6 } }
            },
            lsp_references = {
                theme = 'ivy',
                preview = true,
                path_display = { 'tail' },
                layout_config = { horizontal = { preview_width = 0.6 } }
            },
            highlights = {
                preview = true,
                layout_config = { horizontal = { height = 0.8, width = 0.8, preview_width = 0.6 } }
            },
            buffers = { path_display = { 'filename_first' } },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = 'smart_case',
            }
        }
    }
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('live_grep_args')
end

return M
