require("core.theme")
require("core.options")
require("core.keymaps")

require("mini-deps").setup { job = { timeout = 10000 } }
require("mini-deps").lazy {
    require("plugins.blink-cmp"),
    require("plugins.fidget"),
    require("plugins.flash"),
    require("plugins.gitsigns"),
    require("plugins.illuminate"),
    require("plugins.indent-blankline"),
    require("plugins.lspsaga"),
    require("plugins.lualine"),
    require("plugins.mason"),
    require("plugins.nvim-lspconfig"),
    require("plugins.nvim-luasnip"),
    require("plugins.nvim-surround"),
    require("plugins.nvim-tree"),
    require("plugins.nvim-treesitter"),
    require("plugins.nvim-web-devicons"),
    require("plugins.smart-pairs"),
    require("plugins.telescope"),
    require("plugins.vim-visual-multi"),
    require("plugins.which-key"),
}
