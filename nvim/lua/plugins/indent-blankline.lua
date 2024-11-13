return {
    source = "https://github.com/lukas-reineke/indent-blankline.nvim",
    depence = { "https://github.com/nvim-treesitter/nvim-treesitter" },
    checkout = "v2.20.8",
    config = function()
        Core.setHighlights {
            ["IndentBlanklineChar"]        = { fg = C.DGray, ui = S.Nocombine },
            ["IndentBlanklineContextChar"] = { fg = C.Gray,  ui = S.Nocombine },
        }
        require("indent_blankline").setup {
            space_char_blankline = " ",
            show_current_context = true,
            show_trailing_blankline_indent = false,
            char_highlight_list = { "IndentBlanklineChar" },
            context_highlight_list = { "IndentBlanklineContextChar" }
        }
    end
}
