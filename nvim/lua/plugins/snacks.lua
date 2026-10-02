local M = {
    src = 'https://github.com/folke/snacks.nvim',
    events = { 'VimEnter' },
}

M.config = vim.schedule_wrap(function()
    require('snacks').setup {
        styles   = { input = { relative = 'cursor', row = -3, col = 0 } },
        input    = { icon = '' },
        lazygit  = { configure = false },
        explorer = { trash = true, replace_netrw = true },
        notifier = { style = 'compact', top_down = false },
        picker   = {
            layout = { cycle = true },
            matcher = { frecency = true, history_bonus = true },
            formatters = { file = { filename_first = true }, severity = { level = true }, },
            icons = {
                ui  = { live = ' ', hidden = ' ', ignore = ' ', follow = ' ', selected = '│', unselected = ' ' },
                git = {
                    commit  = ' ', staged   = '+', added     = '+',
                    deleted = '-', ignored  = ' ', modified  = '~',
                    renamed = '~', unmerged = '~', untracked = '+'
                },
            },
            win = {
                input = {
                    keys = {
                        ['<M-j>']      = { 'list_down',           mode = { 'n', 'i' } },
                        ['<M-k>']      = { 'list_up',             mode = { 'n', 'i' } },
                        ['<M-J>']      = { 'list_scroll_down',    mode = { 'n', 'i' } },
                        ['<M-K>']      = { 'list_scroll_up',      mode = { 'n', 'i' } },
                        ['<PageDown>'] = { 'preview_scroll_down', mode = { 'n', 'i' } },
                        ['<PageUp>']   = { 'preview_scroll_up',   mode = { 'n', 'i' } },
                    },
                },
                list = {
                    keys = {
                        ['<M-j>']      = 'list_down',
                        ['<M-k>']      = 'list_up',
                        ['<M-J>']      = 'list_scroll_down',
                        ['<M-K>']      = 'list_scroll_up',
                        ['<PageDown>'] = 'preview_scroll_down',
                        ['<PageUp>']   = 'preview_scroll_up',
                    },
                },
            },
            sources = {
                files = { hidden = true, ignore = true, layout = { preset = 'ivy_split' } },
                buffers = { layout = { preset = 'ivy_split' } },
                command_history = { layout = { preset = 'select' } },
                lsp_definitions = { layout = { preset = 'ivy_split' } },
                lsp_references = { layout = { preset = 'ivy_split' } },
                lsp_implementations = { layout = { preset = 'ivy_split' } },
                lsp_type_definitions = { layout = { preset = 'ivy_split' } },
                explorer = {
                    win = {
                        list = {
                            keys = {
                                ['<BS>']      = 'explorer_up',
                                ['l']         = 'confirm',
                                ['h']         = 'explorer_close',
                                ['a']         = 'explorer_add',
                                ['d']         = 'explorer_del',
                                ['r']         = 'explorer_rename',
                                ['c']         = 'explorer_copy',
                                ['m']         = 'explorer_move',
                                ['o']         = 'confirm', -- explorer_open
                                ['P']         = 'toggle_preview',
                                ['y']         = 'explorer_yank',
                                ['p']         = 'explorer_paste',
                                ['u']         = 'explorer_update',
                                ['<C-c>']     = 'tcd',
                                ['<Leader>/'] = 'picker_grep',
                                ['<Leader>t'] = 'terminal',
                                ['.']         = 'explorer_focus',
                                ['I']         = 'toggle_ignored',
                                ['H']         = 'toggle_hidden',
                                ['Z']         = 'explorer_close_all',
                                [']g']        = 'explorer_git_next',
                                ['[g']        = 'explorer_git_prev',
                                [']d']        = 'explorer_diagnostic_next',
                                ['[d']        = 'explorer_diagnostic_prev',
                                [']w']        = 'explorer_warn_next',
                                ['[w']        = 'explorer_warn_prev',
                                [']e']        = 'explorer_error_next',
                                ['[e']        = 'explorer_error_prev',
                            }
                        }
                    },
                },
            },
        }
    }

    local picker = require('snacks.picker')

    core.sk('n', '<Bslash>\\', picker.pickers,                  { desc = 'Snacks pickers' })
    core.sk('n', '<Bslash>b',  picker.buffers,                  { desc = 'Snacks buffers' })
    core.sk('n', '<Bslash>c',  picker.commands,                 { desc = 'Snacks commands' })
    core.sk('n', '<Bslash>f',  picker.files,                    { desc = 'Snacks files' })
    core.sk('n', '<Bslash>g',  picker.git_status,               { desc = 'Snacks git status' })
    core.sk('n', '<Bslash>h',  picker.help,                     { desc = 'Snacks help' })
    core.sk('n', '<Bslash>j',  picker.jumps,                    { desc = 'Snacks jumps' })
    core.sk('n', '<Bslash>o',  picker.recent,                   { desc = 'Snacks recent' })
    core.sk('n', '<Bslash>q',  picker.qflist,                   { desc = 'Snacks quickfix' })
    core.sk('n', '<Bslash>r',  picker.resume,                   { desc = 'Snacks resume' })
    core.sk('n', '<Bslash>s',  picker.lines,                    { desc = 'Snacks lines' })
    core.sk('n', '<Bslash>S',  picker.grep,                     { desc = 'Snacks grep' })
    core.sk('n', 'gd',         picker.lsp_definitions,          { desc = 'Snacks lsp_definitions' })
    core.sk('n', 'grr',        picker.lsp_references,           { desc = 'Snacks lsp_references' })
    core.sk('n', 'gri',        picker.lsp_implementations,      { desc = 'Snacks lsp_implementations' })
    core.sk('n', 'grt',        picker.lsp_type_definitions,     { desc = 'Snacks lsp_type_definitions' })
    core.sk('n', 'go',         picker.lsp_symbols,              { desc = 'Snacks lsp_symbols' })
    core.sk('n', '<Leader>f',  require('snacks.explorer').open, { desc = 'Snacks explorer' })
    core.sk('n', '<Leader>gg', require('snacks.lazygit').open,  { desc = 'Snacks lazygit' })

    core.sk('n', '<Leader>tf', function()
        require('snacks.terminal').toggle(nil, { count = 1, win = { position = 'float', border = 'rounded' } })
    end, { desc = 'Snacks terminal float' })

    core.sk('n', '<Leader>tb', function()
        require('snacks.terminal').toggle(nil, { count = 2, win = { position = 'bottom' } })
    end, { desc = 'Snacks terminal bottom' })

    core.hl {
        ['SnacksPickerGitStatusUntracked'] = { link = 'Added' }
    }

    vim.api.nvim_create_autocmd('LspProgress', {
        group = vim.api.nvim_create_augroup('snacks.LspProgress', { clear = true }),
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if not client then return end

            local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
            vim.notify(client.name .. ': ' .. vim.lsp.status(), 'info', {
                id = 'lsp_progress',
                title = client.name,
                opts = function(notif)
                    notif.icon = ev.data.params.value.kind == 'end' and ' '
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end
    })
end)

return M
