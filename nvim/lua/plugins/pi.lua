local M = {
    src = 'https://github.com/alex35mil/pi.nvim',
}

M.config = function()
    core.set_keymaps('n', {
        ['<Leader>a'] = function() vim.cmd('Pi') end
    })

    require('pi').setup {}
end

return M
