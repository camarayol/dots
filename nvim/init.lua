require("core.theme")
require("core.options")
require("core.keymaps")

require("mini-deps").setup { job = { timeout = 10000 } }
require("mini-deps").later_add {
    -- UI
    require("plugins.nvim-web-devicons"),
    require("plugins.gitsigns"),
    require("plugins.lualine"),
    require("plugins.nvim-treesitter"),
    require("plugins.indent-blankline"),

    -- LSP
    require("plugins.LuaSnip"),
    require("plugins.nvim-cmp"),
    require("plugins.mason"),
    require("plugins.nvim-lspconfig"),
    require("plugins.lspsaga"),

    -- Tools
    require("plugins.telescope"),
    require("plugins.nvim-tree"),
    require("plugins.flash"),
    require("plugins.smart-pairs"),
    require("plugins.nvim-surround"),
    require("plugins.vim-visual-multi"),
    require("plugins.which-key"),
    -- require("plugins.neogen"),
    -- require("plugins.todo-comments"),
    -- require("plugins.markdown-preview"),
}
