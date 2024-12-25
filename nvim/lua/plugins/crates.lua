return {
    source = "https://github.com/saecki/crates.nvim",
    config = function()
        require("crates").setup {
            completion = { cmp = { enabled = true } }
        }
    end
}
