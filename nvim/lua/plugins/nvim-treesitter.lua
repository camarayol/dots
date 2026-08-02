return {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    events = { 'BufReadPost', 'BufNewFile' },
    build = function()
        vim.api.nvim_echo({
            { 'Treesitter', 'DiagnosticInfo' }, { ': TSUpdate', '' }
        }, true, { verbose = true })

        vim.cmd('TSUpdate')
    end,
    config = function()
        require('nvim-treesitter').setup {}
    end
}
