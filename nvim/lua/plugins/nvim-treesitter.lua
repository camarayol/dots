return {
    source = 'https://github.com/nvim-treesitter/nvim-treesitter',
    hook  = function() vim.cmd('TSUpdate') end,
    config = function()
        require('nvim-treesitter').setup {}
    end
}
