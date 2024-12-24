return {
    source = "https://github.com/iamcco/markdown-preview.nvim",
    hooks = {
        post_install = function() vim.fn["mkdp#util#install"]() end,
        post_checkout = function() vim.fn["mkdp#util#install"]() end
    },
    config = function()
        Core.setKeyMaps {
            { "n", "<leader>mp", "<Cmd>MarkdownPreview<CR>", { desc = "[Markdown]: Preview" } }
        }
        Core.setOptions {
            g = {
                -- specify browser to open preview page
                -- mkdp_browser = core.is_wsl() and "MicrosoftEdge.exe" or "firefox",
                -- auto close current preview window when changing from Markdown buffer to another buffer
                mkdp_auto_close = 0,
                -- echo preview page URL in command line when opening preview page
                mkdp_echo_preview_url = 1,
            }
        }
    end
}
