return {
    source = 'https://github.com/nvim-tree/nvim-tree.lua',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    config = function()
        core.set_mode_keymaps('n', {
            ['<leader>e'] = '<Cmd>NvimTreeFocus<CR>',
            ['<leader>f'] = '<Cmd>NvimTreeToggle<CR>',
        })

        require('nvim-tree').setup {
            on_attach = function(bufnr)
                local api = require('nvim-tree.api')
                local opts = { buffer = bufnr, nowait = true }
                core.set_mode_keymaps('n', {
                    ['O'] = { api.tree.change_root_to_node, opts },
                    ['P'] = { api.tree.change_root_to_parent, opts },
                    ['x'] = { api.fs.cut, opts },
                    ['o'] = { api.node.open.edit, opts },
                    ['<CR>'] = { api.node.open.edit, opts },
                    ['<2-LeftMouse>'] = { api.node.open.edit, opts },
                    ['y'] = { api.fs.copy.node, opts },
                    ['K'] = { api.node.show_info_popup, opts },
                    ['H'] = { api.tree.toggle_help, opts },
                    ['p'] = { api.fs.paste, opts },
                    ['q'] = { api.tree.close, opts },
                    ['D'] = { api.fs.trash, opts },
                    ['F'] = { api.live_filter.start, opts },
                    ['a'] = { api.fs.create, opts },
                    ['d'] = { api.fs.remove, opts },
                    ['r'] = { api.fs.rename, opts },
                    ['R'] = { api.tree.reload, opts },
                    ['W'] = { api.tree.collapse_all, opts },
                    ['E'] = { api.tree.expand_all, opts },
                    ['<Tab>'] = { api.node.open.preview, opts },
                    ['I'] = { api.tree.toggle_gitignore_filter, opts }
                })
            end,
            disable_netrw = true,
            reload_on_bufenter = true,
            renderer = {
                group_empty = true,
                highlight_git = true,
                highlight_opened_files = 'icon',
                root_folder_label = false,
                indent_markers = {
                    enable = true,
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
            trash = { cmd = 'gio trash' },
        }

        local api = require('nvim-tree.api')
        api.events.subscribe(api.events.Event.FileCreated, function(file) vim.cmd('edit ' .. file.fname) end)
    end
}
