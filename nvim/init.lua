require('core')
require('options')

require('packer') {
    require('plugins.copilot'),
    require('plugins.blink-cmp'),
    require('plugins.fidget'),
    require('plugins.flash'),
    require('plugins.gitsigns'),
    require('plugins.image'),
    require('plugins.lualine'),
    require('plugins.mini-clue'),
    require('plugins.mini-indentscope'),
    require('plugins.nvim-luasnip'),
    require('plugins.nvim-surround'),
    require('plugins.nvim-tree'),
    require('plugins.render-markdown'),
    require('plugins.smart-pairs'),
    require('plugins.telescope'),
    require('plugins.vim-visual-multi'),
}
