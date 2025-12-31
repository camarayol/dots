return {
    source = "https://github.com/nvim-treesitter/nvim-treesitter",
    hooks = { post_install = function() vim.cmd("TSUpdate") end },
    config = function()
        require("nvim-treesitter").setup {}

        vim.treesitter.language.register("json5", "json")

        Core.createAutoCommand("FileType", {
            "rust", "cpp", "json", "sql", "markdown", "markdown_inline", "typst"
        }, function() vim.treesitter.start() end)

        Core.setKeyMaps { { "n", "<F2>", "<Cmd>Inspect<CR>" } }
    end
}
