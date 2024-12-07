return {
    source = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    config = function()
        Core.setKeyMaps {
            { "n", "<Leader>mp", function() require("render-markdown").enable() end, { desc = "[Markdown] RenderMarkdown" } }
        }
        Core.setHighlights {
            ["RenderMarkdownCode"]       = { fg = C.None, bg = C.Black },
            ["RenderMarkdownCodeInline"] = { fg = C.None, bg = C.None },
        }

        require("render-markdown").setup {
            sign = { enabled = false },
            code = {
                style = "full",
                width = "full",
                border = "thin",
                position = "left",
                highlight = "RenderMarkdownCode",
                highlight_inline = "RenderMarkdownCodeInline",
            }
        }
    end
}
