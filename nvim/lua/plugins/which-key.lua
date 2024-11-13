return {
    source = "https://github.com/folke/which-key.nvim",
    config = function()
        require("which-key").setup {
            win = {
                border = "single"
            }
        }
    end
}
