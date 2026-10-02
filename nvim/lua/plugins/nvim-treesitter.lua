local M = {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    events = { 'BufReadPost', 'BufNewFile' },
}

M.build = function()
    vim.api.nvim_echo({
        { 'Treesitter: TSUpdate', 'DiagnosticInfo' }
    }, true, { verbose = true })

    vim.cmd('TSUpdate')
end

M.config = function()
    require('nvim-treesitter').setup {}
end

return M
