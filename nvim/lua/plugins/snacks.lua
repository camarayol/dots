local M = {
    src     = 'https://github.com/folke/snacks.nvim',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    events  = { 'CmdUndefined' },
    pattern = { 'Snacks' },
}

core.sk('n', '<Bslash>', function()
    pcall(vim.api.nvim_del_keymap, 'n', '<Bslash>')
    vim.api.nvim_exec_autocmds('CmdUndefined', { pattern = 'Snacks' })
    vim.api.nvim_feedkeys(vim.keycode('<Bslash>'), 'mi', false)
end)

core.sk('n', '<Leader>f', function()
    pcall(vim.api.nvim_del_keymap, 'n', '<Leader>f')
    vim.api.nvim_exec_autocmds('CmdUndefined', { pattern = 'Snacks' })
    vim.api.nvim_feedkeys(vim.keycode('<Leader>f'), 'mi', false)
end)

M.config = function()
    require('snacks').setup {
        styles   = { input = { relative = 'cursor', row = -3, col = 0 } },
        input    = { icon = '' },
        lazygit  = { configure = false },
        explorer = { trash = true, replace_netrw = true },
        notifier = { style = 'compact', top_down = false },
        picker   = {
            actions = {
                qflist = function(picker)
                    local sel = picker:selected()
                    local items = #sel > 0 and sel or picker:items()

                    local qf = {}
                    for _, item in ipairs(items) do
                        qf[#qf + 1] = {
                            bufnr    = item.buf,
                            filename = require('snacks.picker').util.path(item),
                            lnum     = item.pos and item.pos[1] or 1,
                            col      = item.pos and item.pos[2] + 1 or 1,
                            end_lnum = item.end_pos and item.end_pos[1] or nil,
                            end_col  = item.end_pos and item.end_pos[2] + 1 or nil,
                            text     = item.line or item.comment or item.label or item.name or item.detail or item.text,
                            pattern  = item.search,
                            type     = ({ 'E', 'W', 'I', 'N' })[item.severity],
                            valid    = true,
                        }
                    end

                    picker:close()
                    vim.fn.setqflist(qf)

                    vim.schedule(function() require('snacks.picker').qflist() end)
                end,
            },
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
                highlights = {
                    win = {
                        input = { keys = { ['<CR>'] = { { 'yank', 'cancel' }, mode = { 'n', 'i' } } } },
                        list  = { keys = { ['<CR>'] = { { 'yank', 'cancel' }, mode = { 'n', 'i' } } } },
                    },
                },
                git_diff = { layout = { preset = 'sidebar' }, focus = 'list' },
                git_status = { layout = { preset = 'sidebar' }, focus = 'list' },
                qflist = { layout = { preset = 'ivy_split' } },
                command_history = { layout = { preset = 'select' } },
                lsp_definitions = { layout = { preset = 'ivy_split' } },
                lsp_references = { layout = { preset = 'ivy_split' } },
                lsp_implementations = { layout = { preset = 'ivy_split' } },
                lsp_type_definitions = { layout = { preset = 'ivy_split' } },
                recent = { config = function(opts) opts.filter = nil return opts end },
                explorer = {
                    jump = { close = true },
                    layout = { preset = 'sidebar', preview = { enabled = true, main = true } },
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

    core.sk('n', '<Leader>f', function()
        local explorer = picker.get({ source = 'explorer' })[1]
        if not explorer then
            require('snacks.explorer').open()
        elseif explorer:is_focused() then
            explorer:close()
        else
            explorer:focus('list')
        end
    end, { desc = 'Snacks explorer' })

    core.sk('n', '<Leader>gg', require('snacks.lazygit').open, { desc = 'Snacks lazygit' })

    core.hl {
        ['SnacksPickerGitStatusUntracked'] = { link = 'Added' }
    }

    vim.api.nvim_create_autocmd('LspProgress', {
        group = vim.api.nvim_create_augroup('snacks.LspProgress', { clear = true }),
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if not client then return end

            local done = ev.data.params.value.kind == 'end'
            vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
                id      = ev.data.client_id,
                title   = client.name,
                timeout = done and 3000 or false,
            })
        end
    })
end

return M
