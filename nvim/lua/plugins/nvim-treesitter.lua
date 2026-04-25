return {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    hooks  = function() vim.cmd('TSUpdate') end,
    config = function()
        require('nvim-treesitter').setup {}
    end
}
