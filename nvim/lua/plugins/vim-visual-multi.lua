return {
    source = "https://github.com/mg979/vim-visual-multi",
    config = function()
        Core.setOptions {
            g = {
                VM_theme = "iceblue",
                VM_highlight_matches = "underline",
                VM_default_mappings = 0,
                VM_maps = { ["Remove Region"] = "q" }
            }
        }

        Core.setKeyMaps {
            { "n", "<C-k>", "<Plug>(VM-Add-Cursor-Up)",   { noremap = true, silent = true } },
            { "n", "<C-j>", "<Plug>(VM-Add-Cursor-Down)", { noremap = true, silent = true } },
            { "n", "<C-n>", "<Plug>(VM-Find-Under)",      { noremap = true, silent = true } },
        }
    end
}
