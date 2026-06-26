local M = {
    src = 'https://github.com/nvim-tree/nvim-tree.lua',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' }
}

M.config = function()
    core.set_keymaps('n', {
        ['<Leader>e'] = { callback = function() vim.cmd('NvimTreeFocus') end, desc = '[NvimTree] focus filetree' },
        ['<Leader>f'] = { callback = function() vim.cmd('NvimTreeToggle') end, desc = '[NvimTree] toggle filetree' },
    })

    require('nvim-tree').setup {
        on_attach = function(buf)
            local api = require('nvim-tree.api')
            core.set_keymaps('n', {
                ['O']             = { buf = buf, nowait = true, callback = api.tree.change_root_to_node },
                ['P']             = { buf = buf, nowait = true, callback = api.tree.change_root_to_parent },
                ['F']             = { buf = buf, nowait = true, callback = api.live_filter.start },
                ['R']             = { buf = buf, nowait = true, callback = api.tree.reload },
                ['I']             = { buf = buf, nowait = true, callback = api.tree.toggle_gitignore_filter },
                ['W']             = { buf = buf, nowait = true, callback = api.tree.collapse_all },
                ['E']             = { buf = buf, nowait = true, callback = api.tree.expand_all },

                ['m']             = { buf = buf, nowait = true, callback = api.marks.toggle },
                ['M']             = { buf = buf, nowait = true, callback = api.filter.no_bookmark.toggle },

                ['<Tab>']         = { buf = buf, nowait = true, callback = api.node.open.preview },
                ['o']             = { buf = buf, nowait = true, callback = api.node.open.edit },
                ['<CR>']          = { buf = buf, nowait = true, callback = api.node.open.edit },
                ['<2-LeftMouse>'] = { buf = buf, nowait = true, callback = api.node.open.edit },

                ['a']             = { buf = buf, nowait = true, callback = api.fs.create },
                ['x']             = { buf = buf, nowait = true, callback = api.fs.cut },
                ['p']             = { buf = buf, nowait = true, callback = api.fs.paste },
                ['y']             = { buf = buf, nowait = true, callback = api.fs.copy.node },
                ['r']             = { buf = buf, nowait = true, callback = api.fs.rename },
                ['d']             = { buf = buf, nowait = true, callback = api.fs.remove },
                ['D']             = { buf = buf, nowait = true, callback = api.fs.trash },

                ['<Esc>']         = { buf = buf, nowait = true, callback = api.tree.close },
                ['q']             = { buf = buf, nowait = true, callback = api.tree.close },
                ['K']             = { buf = buf, nowait = true, callback = api.node.show_info_popup },
                ['H']             = { buf = buf, nowait = true, callback = api.tree.toggle_help },
            })
        end,
        disable_netrw = true,
        reload_on_bufenter = true,
        view = {
            centralize_selection = false,
            cursorline = true,
            cursorlineopt = 'both',
            debounce_delay = 15,
            side = 'left',
            preserve_window_proportions = false,
            number = false,
            relativenumber = false,
            signcolumn = 'yes',
            width = 30,
            float = {
                enable = false,
                quit_on_focus_loss = true,
                open_win_config = {
                    relative = 'editor',
                    width = math.floor(vim.o.columns * 0.3),
                    height = math.floor(vim.o.lines * 0.9),
                    row = 0,
                    col = 0,
                },
            },
        },
        renderer = {
            group_empty = true,
            highlight_git = true,
            highlight_opened_files = 'icon',
            root_folder_label = false,
            indent_markers = {
                enable = false,
                inline_arrows = true,
                icons = { corner = '└', edge = '│', item = '│', bottom = '─', none = ' ', },
            },
            icons = {
                show = { modified = false },
                symlink_arrow = ' -> ',
                glyphs = {
                    git = {
                        unstaged  = '~',
                        staged    = '+',
                        unmerged  = '~',
                        renamed   = '+',
                        untracked = '+',
                        deleted   = '-',
                        ignored   = '',
                    }
                }
            },
            special_files = { 'README.md', 'readme.md', 'Makefile', 'CMakeLists.txt' },
        },
        update_focused_file = { enable = true, update_root = false },
        diagnostics = { enable = true, icons = { hint = '', info = '', warning = '', error = '', }, },
        actions = { expand_all = { exclude = { '.git', 'build' } } },
        trash = { cmd = 'trash' },
    }

    local api = require('nvim-tree.api')
    api.events.subscribe(api.events.Event.FileCreated, function(file) vim.cmd('edit ' .. file.fname) end)
end

return M
