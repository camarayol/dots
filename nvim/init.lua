require('core')
require('colors')
require('options')
require('keymaps')

require('mini-deps').setup {}
require('mini-deps').lazy(function()
    Core.prependEnvPath(vim.fn.stdpath('data') .. '/mason/bin')
    vim.lsp.enable { 'lua_ls', 'rust_analyzer', 'clangd', 'tinymist' }
end)
require('mini-deps').lazy {
    require('plugins.blink-cmp'),
    require('plugins.fidget'),
    require('plugins.flash'),
    require('plugins.gitsigns'),
    require('plugins.illuminate'),
    require('plugins.lspsaga'),
    require('plugins.lualine'),
    require('plugins.mason'),
    require('plugins.mini-indentscope'),
    require('plugins.nvim-luasnip'),
    require('plugins.nvim-surround'),
    require('plugins.nvim-tree'),
    require('plugins.nvim-treesitter'),
    require('plugins.nvim-web-devicons'),
    require('plugins.smart-pairs'),
    require('plugins.telescope'),
    require('plugins.vim-visual-multi'),
    require('plugins.which-key'),
}
