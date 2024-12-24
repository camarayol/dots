return {
    source = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    config = function()
        Core.setKeyMaps {
            { "n", "<Leader>mp", function() require("render-markdown").enable() end, { desc = "[Markdown] RenderMarkdown" } }
        }
        Core.setHighlights {
            ['RenderMarkdownH1Bg'] = { fg = C.Orange, bg = C.DOrange },
            ['RenderMarkdownH2Bg'] = { fg = C.Orange, bg = C.DOrange },
            ['RenderMarkdownH3Bg'] = { fg = C.Orange, bg = C.DOrange },
            ['RenderMarkdownH4Bg'] = { fg = C.Orange, bg = C.DOrange },
            ['RenderMarkdownH6Bg'] = { fg = C.Orange, bg = C.DOrange },
            ['RenderMarkdownH5Bg'] = { fg = C.Orange, bg = C.DOrange },
            ["RenderMarkdownCode"] = { fg = C.None,   bg = C.Black   },
            ["RenderMarkdownCodeInline"] = { fg = C.None, bg = C.None },
        }

        require("render-markdown").setup {
            sign = { enabled = false },
            heading = { icons = {}, position = "inline" },
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
