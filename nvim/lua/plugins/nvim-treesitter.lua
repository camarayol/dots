return {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    build = function() vim.cmd('TSUpdate') end,
    config = function()
        require('nvim-treesitter').setup {}
    end
}
