return {
    source = "https://github.com/nvim-treesitter/nvim-treesitter",
    hooks = { post_install = function() vim.cmd("TSUpdate") end },
    config = function()
        Core.setKeyMaps { { "n", "<F2>", "<Cmd>Inspect<CR>" } }

        Core.createAutoCommand({ "BufReadPost", "BufNewFile" }, nil, function()
            if vim.bo.filetype ~= "" then
                pcall(vim.treesitter.start)
            end
        end)

        vim.treesitter.language.register("json5", "json")

        require("nvim-treesitter").setup {}
    end
}
