local M = {
    src = 'https://github.com/alex35mil/pi.nvim',
}

M.config = function()
    core.set_keymaps('n', {
        ['<Leader>a'] = function() vim.cmd('Pi') end
    })

    core.set_keymaps('v', {
        ['<Leader>a'] = function() vim.cmd('PiSendMention') end
    })

    core.create_autocommand('FileType', {
        pattern = 'pi-chat-history',
        callback = function(ev)
            vim.bo[ev.buf].syntax = ''
            vim.treesitter.start(ev.buf, 'markdown')
        end
    })

    require('pi').setup {}
end

return M
