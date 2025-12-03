return {
    source = "https://github.com/nvim-tree/nvim-tree.lua",
    depends = { "https://github.com/nvim-tree/nvim-web-devicons" },
    config = function()
        Core.setKeyMaps {
            { "n", "<leader>e", "<Cmd>NvimTreeFocus<CR>",  { desc = "[NvimTree] Focus"  } },
            { "n", "<leader>f", "<Cmd>NvimTreeToggle<CR>", { desc = "[NvimTree] Toggle" } }
        }
        Core.linkHighlights {
            ["NvimTreeGitNew"]           = "GitSignsAdd",
            ["NvimTreeGitDirty"]         = "GitSignsChange",
            ["NvimTreeCursorLine"]       = "CursorLine",
            ["NvimTreeOpenedFolderIcon"] = "NvimTreeOpenedFolderName",
            ["NvimTreeIndentMarker"]     = "IndentBlanklineContextChar",
        }

        require("nvim-tree").setup {
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                local keymaps = {
                    { "n", "O",             api.tree.change_root_to_node,     opts("CD")                },
                    { "n", "P",             api.tree.change_root_to_parent,   opts("Up")                },
                    { "n", "x",             api.fs.cut,                       opts("Cut")               },
                    { "n", "o",             api.node.open.edit,               opts("Open")              },
                    { "n", "<CR>",          api.node.open.edit,               opts("Open")              },
                    { "n", "<2-LeftMouse>", api.node.open.edit,               opts("Open")              },
                    { "n", "y",             api.fs.copy.node,                 opts("Copy")              },
                    { "n", "K",             api.node.show_info_popup,         opts("Info")              },
                    { "n", "H",             api.tree.toggle_help,             opts("Help")              },
                    { "n", "p",             api.fs.paste,                     opts("Paste")             },
                    { "n", "q",             api.tree.close,                   opts("Close")             },
                    { "n", "D",             api.fs.trash,                     opts("Trash")             },
                    { "n", "F",             api.live_filter.start,            opts("Filter")            },
                    { "n", "a",             api.fs.create,                    opts("Create")            },
                    { "n", "d",             api.fs.remove,                    opts("Delete")            },
                    { "n", "r",             api.fs.rename,                    opts("Rename")            },
                    { "n", "R",             api.tree.reload,                  opts("Refresh")           },
                    { "n", "W",             api.tree.collapse_all,            opts("Collapse")          },
                    { "n", "E",             api.tree.expand_all,              opts("Expand All")        },
                    { "n", "<Tab>",         api.node.open.preview,            opts("Open Preview")      },
                    { "n", "I",             api.tree.toggle_gitignore_filter, opts("Toggle Git Ignore") },
                };
                Core.setKeyMaps(keymaps)
            end,
            disable_netrw = true,
            reload_on_bufenter = true,
            renderer = {
                group_empty = true,
                highlight_git = true,
                highlight_opened_files = "icon",
                root_folder_label = false,
                indent_markers = {
                    enable = true,
                    inline_arrows = true,
                    icons = { corner = "└", edge = "│", item = "│", bottom = "─", none = " ", },
                },
                icons = {
                    show = { modified = false },
                    symlink_arrow = " -> ",
                    glyphs = {
                        git = {
                            unstaged  = "~",
                            staged    = "+",
                            unmerged  = "~",
                            renamed   = "+",
                            untracked = "+",
                            deleted   = "-",
                            ignored   = "",
                        }
                    }
                },
                special_files = { "README.md", "readme.md", "Makefile", "CMakeLists.txt" },
            },
            update_focused_file = { enable = true, update_root = false },
            diagnostics = { enable = true, icons = { hint = "", info = "", warning = "", error = "", }, },
            actions = { expand_all = { exclude = { ".git", "build" } } },
            trash = { cmd = "gio trash" },
        }

        local api = require("nvim-tree.api")
        api.events.subscribe(api.events.Event.FileCreated, function(file) vim.cmd("edit " .. file.fname) end)
    end
}
