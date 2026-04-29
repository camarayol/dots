return {
    src = 'https://github.com/nvim-tree/nvim-tree.lua',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    config = function()
        core.nvim_set_highlights {
            ['NvimTreeGitNew']           = { link = 'Added' },
            ['NvimTreeGitDirty']         = { link = 'Changed' },
            ['NvimTreeGitDirtyIcon']     = { link = 'Changed' },
            ['NvimTreeCursorLine']       = { link = 'CursorLine' },
            ['NvimTreeOpenedFolderIcon'] = { link = 'NvimTreeOpenedFolderName' },
            ['NvimTreeIndentMarker']     = { link = 'IndentScopeOther' },
        }

        core.set_mode_keymaps('n', {
            ['<leader>e'] = '<Cmd>NvimTreeFocus<CR>',
            ['<leader>f'] = '<Cmd>NvimTreeToggle<CR>',
        })

        require('nvim-tree').setup {
            on_attach = function(buffer)
                local api = require('nvim-tree.api')
                local opts = { buffer = buffer, noremap = true, silent = true, nowait = true }
                core.set_mode_keymaps('n', {
                    ['O']             = { api.tree.change_root_to_node,     opts },
                    ['P']             = { api.tree.change_root_to_parent,   opts },
                    ['F']             = { api.live_filter.start,            opts },
                    ['R']             = { api.tree.reload,                  opts },
                    ['I']             = { api.tree.toggle_gitignore_filter, opts },
                    ['W']             = { api.tree.collapse_all,            opts },
                    ['E']             = { api.tree.expand_all,              opts },

                    ['m']             = { api.marks.toggle,                 opts },
                    ['M']             = { api.filter.no_bookmark.toggle,    opts },

                    ['<Tab>']         = { api.node.open.preview,            opts },
                    ['o']             = { api.node.open.edit,               opts },
                    ['<CR>']          = { api.node.open.edit,               opts },
                    ['<2-LeftMouse>'] = { api.node.open.edit,               opts },

                    ['a']             = { api.fs.create,                    opts },
                    ['x']             = { api.fs.cut,                       opts },
                    ['p']             = { api.fs.paste,                     opts },
                    ['y']             = { api.fs.copy.node,                 opts },
                    ['r']             = { api.fs.rename,                    opts },
                    ['d']             = { api.fs.remove,                    opts },
                    ['D']             = { api.fs.trash,                     opts },

                    ['<Esc>']         = { api.tree.close,                   opts },
                    ['q']             = { api.tree.close,                   opts },
                    ['K']             = { api.node.show_info_popup,         opts },
                    ['H']             = { api.tree.toggle_help,             opts },
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
                    enable = true,
                    quit_on_focus_loss = true,
                    open_win_config = {
                        relative = 'editor',
                        border = 'rounded',
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
}
