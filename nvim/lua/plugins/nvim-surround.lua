return {
    source = "https://github.com/kylechui/nvim-surround",
    config = function()
        require("nvim-surround").setup {
            keymaps = {
                normal = "ys",
                visual = "S",
                delete = "ds",
                change = "cs",
            }
        }
    end
}
