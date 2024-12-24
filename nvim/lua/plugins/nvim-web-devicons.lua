return {
    source = "https://github.com/nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").setup {
            override = {
                ["md"]       = { icon = "󰂺", color = C.Orange, name = "Markdown" },
                ["markdown"] = { icon = "󰂺", color = C.Orange, name = "Markdown" },
                ["readme"]   = { icon = "󰂺", color = C.Orange, name = "Readme"   },
            },
            override_by_filename = {},
            override_by_extension = {},
        }
    end
}
