return {
    source = "https://github.com/nvim-tree/nvim-web-devicons",
    config = function()
        require("nvim-web-devicons").set_icon {
            ["md"]          = { icon = "", color = C.Blue, name = "Markdown"   },
            [".gitignore"]  = { icon = "", color = C.DRed, name = "GitIgnore"  },
            [".gitmodules"] = { icon = "", color = C.DRed, name = "GitModules" },
        }
    end
}
