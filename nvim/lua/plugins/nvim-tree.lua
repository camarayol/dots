core.set_keymaps {
    { modes = 'n', lhs = '<Leader>e', rhs = '<Cmd>NvimTreeFocus<CR>',  opts = { desc = 'NvimTree focus' } },
    { modes = 'n', lhs = '<Leader>f', rhs = '<Cmd>NvimTreeToggle<CR>', opts = { desc = 'NvimTree toggle' } },
}

local M = {
    src = 'https://github.com/nvim-tree/nvim-tree.lua',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    events = { 'CmdUndefined' },
    pattern = { 'NvimTreeFocus', 'NvimTreeToggle' }
}

M.config = function()
    require('nvim-tree').setup {
        on_attach = function(buf)
            local api = require('nvim-tree.api')

            core.set_keymaps {
                { modes = 'n', lhs = 'O',             rhs = api.tree.change_root_to_node,     opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'P',             rhs = api.tree.change_root_to_parent,   opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'F',             rhs = api.live_filter.start,            opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'R',             rhs = api.tree.reload,                  opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'I',             rhs = api.tree.toggle_gitignore_filter, opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'W',             rhs = api.tree.collapse_all,            opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'E',             rhs = api.tree.expand_all,              opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'm',             rhs = api.marks.toggle,                 opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'M',             rhs = api.filter.no_bookmark.toggle,    opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = '<Tab>',         rhs = api.node.open.preview,            opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'o',             rhs = api.node.open.edit,               opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = '<CR>',          rhs = api.node.open.edit,               opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = '<2-LeftMouse>', rhs = api.node.open.edit,               opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'a',             rhs = api.fs.create,                    opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'x',             rhs = api.fs.cut,                       opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'p',             rhs = api.fs.paste,                     opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'y',             rhs = api.fs.copy.node,                 opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'r',             rhs = api.fs.rename,                    opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'd',             rhs = api.fs.remove,                    opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'D',             rhs = api.fs.trash,                     opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = '<Esc>',         rhs = api.tree.close,                   opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'q',             rhs = api.tree.close,                   opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'K',             rhs = api.node.show_info_popup,         opts = { buf = buf, nowait = true } },
                { modes = 'n', lhs = 'H',             rhs = api.tree.toggle_help,             opts = { buf = buf, nowait = true } },
            }
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
