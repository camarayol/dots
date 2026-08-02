require('core')
require('options')

require('packer') {
    require('plugins.blink-cmp'),
    require('plugins.fzf'),
    require('plugins.gitsigns'),
    require('plugins.hop'),
    require('plugins.lualine'),
    require('plugins.mini-clue'),
    require('plugins.nvim-luasnip'),
    require('plugins.nvim-surround'),
    require('plugins.nvim-tree'),
    require('plugins.render-markdown'),
    require('plugins.nvim-treesitter'),
    require('plugins.pi'),
    require('plugins.smart-pairs'),
    require('plugins.vim-visual-multi'),
}
