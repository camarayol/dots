return {
    source = "https://github.com/j-hui/fidget.nvim",
    depends = { "https://github.com/williamboman/nvim-lspconfig" },
    config = function()
        require("fidget").setup {
            notification = {
                window = {
                    winblend = 0,
                    border = "rounded"
                }
            }
        }
    end
}
