core.set_keymaps {
    { modes = 'n', lhs = '<Bslash>\\', rhs = '<Cmd>Telescope builtin<CR>',    opts = { desc = 'Telescope builtin' } },
    { modes = 'n', lhs = '<Bslash>b',  rhs = '<Cmd>Telescope buffers<CR>',    opts = { desc = 'Telescope buffers' } },
    { modes = 'n', lhs = '<Bslash>g',  rhs = '<Cmd>Telescope git_status<CR>', opts = { desc = 'Telescope git_status' } },
    { modes = 'n', lhs = '<Bslash>h',  rhs = '<Cmd>Telescope help_tags<CR>',  opts = { desc = 'Telescope help_tags' } },
    { modes = 'n', lhs = '<Bslash>j',  rhs = '<Cmd>Telescope jumplist<CR>',   opts = { desc = 'Telescope jumplist' } },
    { modes = 'n', lhs = '<Bslash>o',  rhs = '<Cmd>Telescope oldfiles<CR>',   opts = { desc = 'Telescope oldfiles' } },
    { modes = 'n', lhs = '<Bslash>q',  rhs = '<Cmd>Telescope quickfix<CR>',   opts = { desc = 'Telescope quickfix' } },
    { modes = 'n', lhs = '<Bslash>S',  rhs = '<Cmd>Telescope live_grep<CR>',  opts = { desc = 'Telescope live_grep_args' } },
    {
        modes = 'n', lhs = '<Bslash>s', rhs = '<Cmd>Telescope current_buffer_fuzzy_find<CR>',
        opts = { desc = 'Telescope current_buffer_fuzzy_find' }
    },
    {
        modes = 'n', lhs = '<Bslash>f', rhs = '<Cmd>Telescope find_files hidden=true no_ignore=true<CR>',
        opts = { desc = 'Telescope find_files' }
    },
}

local M = {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    depends = {
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/nvim-telescope/telescope-ui-select.nvim',
        {
            src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
            build = function(ev)
                vim.system({ 'make' }, { cwd = ev.path }, vim.schedule_wrap(function(out)
                    vim.api.nvim_echo({
                        { 'Telescope-fzf-native', out.code == 0 and 'DiagnosticOk' or 'DiagnosticError' },
                        { ': build ' .. out.code == 0 and 'success!' or 'failed!', '' }
                    }, true, { verbose = true })
                end))
            end
        },
    },
    events = { 'CmdUndefined' },
    pattern = { 'Telescope', 'Pi', 'PiResume' }
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
                    ['<C-j>']      = a.preview_scrolling_down,
                    ['<C-k>']      = a.preview_scrolling_up,
                    ['<PageUp>']   = a.preview_scrolling_up,
                    ['<PageDown>'] = a.preview_scrolling_down,
                },
                i = {
                    ['<Esc>']      = a.close,
                    ['<CR>']       = a.select_default,
                    ['<M-j>']      = a.move_selection_next,
                    ['<M-k>']      = a.move_selection_previous,
                    ['<C-q>']      = a.smart_send_to_qflist + a.open_qflist,
                    ['<C-j>']      = a.preview_scrolling_down,
                    ['<C-k>']      = a.preview_scrolling_up,
                    ['<PageUp>']   = a.preview_scrolling_up,
                    ['<PageDown>'] = a.preview_scrolling_down,
                }
            }
        },
        extensions = {
            ['fzf'] = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = 'smart_case' },
            ['ui-select'] = { require('telescope.themes').get_dropdown() }
        }
    }

    require('telescope').load_extension('fzf')
    require('telescope').load_extension('ui-select')
end

return M
