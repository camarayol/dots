local function build(params)
    vim.notify("[blink.cmp] building ...", vim.log.levels.INFO)
    local ret = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
    if ret.code == 0 then
        vim.notify("[blink.cmp] build success!", vim.log.levels.INFO)
    else
        vim.notify("[blink.cmp] build failed!", vim.log.levels.ERROR)
    end
end

-- https://cmp.saghen.dev/configuration/reference.html
return {
    source = "https://github.com/saghen/blink.cmp",
    hooks = { post_install = build, post_checkout = build },
    config = function()
        Core.linkHighlights({
            ["BlinkCmpGhostText"] = "Comment",
        })

        require("blink.cmp").setup {
            completion = {
                list = { selection = { preselect = true, auto_insert = false } },
                menu = {
                    min_width = 30,
                    max_height = 20,
                    border = "single",
                    draw = {
                        treesitter = { "lsp" },
                        columns = { { "kind_icon", gap = 1, "label", "label_description", "kind" } }
                    }
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 50,
                    update_delay_ms = 50,
                    treesitter_highlighting = true,
                    window = {
                        min_width  = 30,
                        max_width  = 80,
                        max_height = 60,
                        border     = "single"
                    }
                },
                ghost_text = { enabled = true },
            },
            signature = { enabled = true, window = { border = "single" } },
            keymap = {
                preset = "none",
                ["<Esc>"] = { "hide", "fallback" },
                ["<Tab>"] = { function(cmp) return cmp.snippet_active() and cmp.accept() or cmp.select_and_accept() end, "fallback" },
                ["<M-j>"] = { "select_next", "fallback" },
                ["<M-k>"] = { "select_prev", "fallback" },
                ["<M-n>"] = { "snippet_forward", "fallback" },
                ["<M-p>"] = { "snippet_backward", "fallback" },
                ["<C-j>"] = { "scroll_documentation_down", "fallback" },
                ["<C-k>"] = { "scroll_documentation_up", "fallback" },
            },
            snippets = { preset = "luasnip" },
            appearance = { nerd_font_variant = "mono" },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
        }
    end
}
