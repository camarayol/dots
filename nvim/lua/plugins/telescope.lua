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
        ['<Bslash>\\'] = { b.builtin,    { desc = 'telescope builtin'    } },
        ['<Bslash>b']  = { b.buffers,    { desc = 'telescope buffers'    } },
        ['<Bslash>f']  = { b.find_files, { desc = 'telescope find_files' } },
        ['<Bslash>g']  = { b.git_status, { desc = 'telescope git_status' } },
        ['<Bslash>h']  = { b.help_tags,  { desc = 'telescope help_tags'  } },
        ['<Bslash>j']  = { b.jumplist,   { desc = 'telescope jumplist'   } },
        ['<Bslash>o']  = { b.oldfiles,   { desc = 'telescope oldfiles'   } },
        ['<Bslash>q']  = { b.quickfix,   { desc = 'telescope quickfix'   } },
        ['<Bslash>S']  = { b.live_grep,  { desc = 'telescope live_grep'  } },
        ['<Bslash>s']  = { b.current_buffer_fuzzy_find, { desc = 'telescope current_buffer_fuzzy_find' } },
    })

    require('telescope').setup {
        defaults = require('telescope.themes').get_ivy {
            path_display = { 'tail' },
            dynamic_preview_title = true,
            sorting_strategy = 'ascending',
            layout_config = {
                bottom_pane = { preview_width = 0.6 },
                horizontal = { prompt_position = 'top', height = 0.6, width = 0.6 }
            },
            -- cache_picker = { num_pickers = 10, limit_entries = 1000, ignore_empty_prompt = true },
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
