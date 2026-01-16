return {
    source = "https://github.com/j-hui/fidget.nvim",
    config = function()
        require("fidget").setup {
            notification = {
                override_vim_notify = true,
                window = {
                    winblend = 0,
                    border = "rounded"
                }
            }
        }
    end
}
