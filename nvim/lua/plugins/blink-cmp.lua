-- https://cmp.saghen.dev/configuration/reference.html
local M  = {
    source = 'https://github.com/saghen/blink.cmp',
    depends = { 'https://github.com/L3MON4D3/LuaSnip' },
}

M.hooks  = function(ev)
    vim.notify('[blink.cmp] building ...')
    vim.system({ 'cargo', 'build', '--release' }, { cwd = ev.path }, vim.schedule_wrap(function(out)
        if out.code == 0 then
            vim.notify('[blink.cmp] build success!')
        else
            vim.notify('[blink.cmp] build failed! ' .. out.stderr, vim.log.levels.WARN)
        end
    end))
end

M.config = function()
    require('blink.cmp').setup {
        completion = {
            -- list = { selection = { preselect = true, auto_insert = function(ctx) return ctx.mode == 'cmdline' end } },
            list = { selection = { preselect = true, auto_insert = true } },
            accept = {
                auto_brackets = {
                    enabled = true,
                    -- https://github.com/Saghen/blink.cmp/issues/359
                    force_allow_filetypes = { 'rust' },
                }
            },
            menu = {
                min_width = 30,
                max_height = 20,
                border = 'rounded',
                draw = {
                    treesitter = { 'lsp' },
                    columns = { { 'kind_icon', gap = 1, 'label', 'label_description', 'kind' } }
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
                    border     = 'rounded'
                }
            },
            ghost_text = { enabled = false },
        },
        signature = { enabled = true, window = { border = 'rounded' } },
        keymap = {
            preset = 'none',
            ['<Esc>'] = { 'hide', 'fallback' },
            ['<Tab>'] = { function(cmp) return cmp.snippet_active() and cmp.accept() or cmp.select_and_accept() end, 'fallback' },
            ['<M-j>'] = { 'select_next', 'fallback' },
            ['<M-k>'] = { 'select_prev', 'fallback' },
            ['<M-n>'] = { 'snippet_forward', 'fallback' },
            ['<M-p>'] = { 'snippet_backward', 'fallback' },
            ['<C-j>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-k>'] = { 'scroll_documentation_up', 'fallback' },
        },
        cmdline = {
            enabled = true,
            completion = { menu = { auto_show = true } },
            keymap = {
                preset = 'none',
                -- <Esc> fallback will automatic execution commands.
                ['<Tab>'] = { 'accept', 'fallback' },
                ['<M-j>'] = { 'select_next', 'fallback' },
                ['<M-k>'] = { 'select_prev', 'fallback' },
            }
        },
        snippets = { preset = 'luasnip' },
        appearance = { nerd_font_variant = 'mono' },
        sources = {
            default = { 'snippets', 'path', 'buffer', 'lsp' },
            providers = { path = { opts = { show_hidden_files_by_default = true } } }
        },
    }
end

return M
