return {
    src = 'https://github.com/j-hui/fidget.nvim',
    events = { 'LspAttach' },
    config = function()
        require('fidget').setup {
            notification = {
                override_vim_notify = false,
                window = {
                    winblend = 0,
                    border = 'rounded'
                }
            }
        }
    end
}
