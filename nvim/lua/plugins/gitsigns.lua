local M = {
    src = 'https://github.com/lewis6991/gitsigns.nvim'
}

M.config = function()
    core.nvim_set_highlights {
        ['GitSignsCurrentLineBlame'] = { link = 'Comment' },
    }
    require('gitsigns').setup {
        on_attach                    = function(buf)
            local gs = require('gitsigns')
            core.set_keymaps('n', {
                ['[c'] = {
                    buf = buf, desc = '[Gitsigns] prev_hunk',
                    callback = function()
                        return vim.wo.diff and vim.cmd.normal { '[c', bang = true } or gs.prev_hunk()
                    end
                },
                [']c'] = {
                    buf = buf, desc = '[Gitsigns] next_hunk',
                    callback = function()
                        return vim.wo.diff and vim.cmd.normal { ']c', bang = true } or gs.next_hunk()
                    end,
                },
                ['<Leader>gr'] = { buf = buf, desc = '[Gitsigns] reset_hunk', callback = gs.reset_hunk },
                ['<Leader>gv'] = { buf = buf, desc = '[Gitsigns] preview_hunk_inline', callback = gs.preview_hunk_inline },
                ['<Leader>gd'] = { buf = buf, desc = '[Gitsigns] diffthis', callback = gs.diffthis },
            })
        end,
        signs = {
            add          = { text = '▌' },
            change       = { text = '▌' },
            delete       = { text = '▌' },
            topdelete    = { text = '▌' },
            changedelete = { text = '▌' },
            untracked    = { text = '▌' },
        },
        signs_staged                 = {
            add          = { text = '▌' },
            change       = { text = '▌' },
            delete       = { text = '▌' },
            topdelete    = { text = '▌' },
            changedelete = { text = '▌' },
            untracked    = { text = '▌' },
        },
        signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
        numhl                        = true,  -- Toggle with `:Gitsigns toggle_numhl`
        linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir                 = { interval = 1000, follow_files = true },
        attach_to_untracked          = true,
        current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts      = { virt_text = true, virt_text_pos = 'eol', delay = 100, ignore_whitespace = false, },
        current_line_blame_formatter = '    <author> <committer_time:%R>: <summary>',
        sign_priority                = 6,
        update_debounce              = 100,
        status_formatter             = nil,   -- Use default
        max_file_length              = 40000, -- Disable if file is longer than this (in lines)
        preview_config               = { border = 'rounded', style = 'minimal', relative = 'cursor', row = 0, col = 1 },
    }
end

return M
