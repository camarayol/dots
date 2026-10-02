require('core')
require('options')

require('packer') {
    require('plugins.blink-cmp'),
    require('plugins.gitsigns'),
    require('plugins.lualine'),
    require('plugins.mini-clue'),
    require('plugins.nvim-luasnip'),
    require('plugins.nvim-surround'),
    require('plugins.render-markdown'),
    require('plugins.nvim-treesitter'),
    require('plugins.pi'),
    require('plugins.snacks'),
    require('plugins.vim-visual-multi'),
}
