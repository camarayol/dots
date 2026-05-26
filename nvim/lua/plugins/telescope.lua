local M = {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
}

M.depends = {
    'https://github.com/nvim-lua/plenary.nvim',
    {
        src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
        build = function(ev)
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

    require('telescope').setup {
        defaults = {
            path_display = { 'tail' },
            dynamic_preview_title = true,
            sorting_strategy = 'ascending',
            borderchars = {
                prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
                results = { " " },
                preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            },
            layout_strategy = 'bottom_pane',
            layout_config = {
                bottom_pane = { prompt_position = 'top', height = 0.6, width = 1.0, preview_width = 0.6 },
                horizontal  = { prompt_position = 'top', height = 0.6, width = 0.6, preview_width = 0.6 },
                cursor      = { results_title = false, height = 10, width = 100 }
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
            fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case' }
        }
    }

    require('telescope').load_extension('fzf')

    core.set_keymaps('n', {
        ['<Bslash>\\'] = { callback = b.builtin,    desc = '[Telescope] builtin' },
        ['<Bslash>b']  = { callback = b.buffers,    desc = '[Telescope] buffers' },
        ['<Bslash>f']  = { callback = b.find_files, desc = '[Telescope] find_files' },
        ['<Bslash>g']  = { callback = b.git_status, desc = '[Telescope] git_status' },
        ['<Bslash>h']  = { callback = b.help_tags,  desc = '[Telescope] help_tags' },
        ['<Bslash>j']  = { callback = b.jumplist,   desc = '[Telescope] jumplist' },
        ['<Bslash>o']  = { callback = b.oldfiles,   desc = '[Telescope] oldfiles' },
        ['<Bslash>q']  = { callback = b.quickfix,   desc = '[Telescope] quickfix' },
        ['<Bslash>S']  = { callback = b.live_grep,  desc = '[Telescope] live_grep_args' },
        ['<Bslash>s']  = { callback = b.current_buffer_fuzzy_find, desc = '[Telescope] current_buffer_fuzzy_find' },
    })
end

return M
