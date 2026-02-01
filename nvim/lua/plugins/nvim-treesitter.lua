return {
    source = 'https://github.com/nvim-treesitter/nvim-treesitter',
    hooks = { post_install = function() vim.cmd('TSUpdate') end },
    config = function()
        require('nvim-treesitter').setup {}
    end
}
