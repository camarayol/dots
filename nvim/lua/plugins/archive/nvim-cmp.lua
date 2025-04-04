return {
    source = "https://github.com/hrsh7th/nvim-cmp",
    depends = {
        "https://github.com/hrsh7th/cmp-cmdline",
        "https://github.com/hrsh7th/cmp-nvim-lsp",
        "https://github.com/hrsh7th/cmp-buffer",
        "https://github.com/hrsh7th/cmp-path",
        "https://github.com/saadparwaiz1/cmp_luasnip",
    },
    config = function()
        Core.setHighlights {
            ["CmpItemAbbrMatch"]         = { fg = C.Blue   },
            ["CmpItemAbbrDeprecated"]    = { fg = C.Gray   },
            ["CmpItemAbbrMatchFuzzy"]    = { fg = C.Blue   },
            ["CmpItemKindText"]          = { fg = C.White  },
            ["CmpItemKindMethod"]        = { fg = C.Purple },
            ["CmpItemKindFunction"]      = { fg = C.Purple },
            ["CmpItemKindConstructor"]   = { fg = C.Orange },
            ["CmpItemKindField"]         = { fg = C.Orange },
            ["CmpItemKindVariable"]      = { fg = C.Yellow },
            ["CmpItemKindClass"]         = { fg = C.Yellow },
            ["CmpItemKindInterface"]     = { fg = C.Purple },
            ["CmpItemKindModule"]        = { fg = C.Yellow },
            ["CmpItemKindProperty"]      = { fg = C.Orange },
            ["CmpItemKindUnit"]          = { fg = C.Orange },
            ["CmpItemKindValue"]         = { fg = C.Blue   },
            ["CmpItemKindEnum"]          = { fg = C.Blue   },
            ["CmpItemKindKeyword"]       = { fg = C.Purple },
            ["CmpItemKindSnippet"]       = { fg = C.Yellow },
            ["CmpItemKindColor"]         = { fg = C.Orange },
            ["CmpItemKindFile"]          = { fg = C.Orange },
            ["CmpItemKindReference"]     = { fg = C.Orange },
            ["CmpItemKindFolder"]        = { fg = C.Orange },
            ["CmpItemKindEnumMember"]    = { fg = C.Blue   },
            ["CmpItemKindConstant"]      = { fg = C.Orange },
            ["CmpItemKindStruct"]        = { fg = C.Yellow },
            ["CmpItemKindEvent"]         = { fg = C.Orange },
            ["CmpItemKindOperator"]      = { fg = C.Orange },
            ["CmpItemKindTypeParameter"] = { fg = C.Purple },
        }

        local cmp = require("cmp")
        local luasnip = require("luasnip")
        cmp.setup {
            sorting = {
                priority_weight = 2,
                comparators = {
                    cmp.config.compare.locality,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.score,  -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
                    cmp.config.compare.offset,
                    cmp.config.compare.order,
                    cmp.config.compare.length,
                    cmp.config.compare.exact,
                    cmp.config.compare.locality,
                }
            },
            preselect = cmp.PreselectMode.None,
            completion = { completeopt = "menu,menuone,noinsert" },
            view = { docs = { auto_open = true } },
            window = {
                completion = { border = "rounded" },
                documentation = { border = "rounded" }
            },
            snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
            sources = cmp.config.sources {
                { name = "luasnip",  priority = 7 },
                { name = "nvim_lsp", priority = 8 },
                { name = "path",     priority = 7 },
                { name = "buffer",   priority = 7 },
                { name = "crates",   priority = 0 },
            },
            mapping = {
                ["<Tab>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
                ["<Esc>"] = cmp.mapping(function(fallback)
                    return cmp.visible() and cmp.close() or fallback()
                end, { "i", "s" }),
                ["<M-j>"] = cmp.mapping(function()
                    return cmp.visible() and cmp.select_next_item() or
                        luasnip.choice_active() and luasnip.change_choice(1)
                end, { "i", "s", "c" }),
                ["<M-k>"] = cmp.mapping(function()
                    return cmp.visible() and cmp.select_prev_item() or
                        luasnip.choice_active() and luasnip.change_choice(-1)
                end, { "i", "s", "c" }),
                ["<M-n>"] = cmp.mapping(function()
                    return luasnip.expand_or_jumpable() and luasnip.expand_or_jump()
                end, { "i", "s" }),
                ["<M-p>"] = cmp.mapping(function()
                    return luasnip.jumpable(-1) and luasnip.jump()
                end, { "i", "s" }),
            },
            formatting = {
                fields = { "kind", "abbr" },
                format = function(_, item)
                    local width = 30
                    item.menu = ""
                    item.abbr = #item.abbr > width
                        and vim.fn.strcharpart(item.abbr, 0, width - 3) .. "..."
                        or item.abbr .. (" "):rep(width - #item.abbr)
                    return item
                end,
            },
        }

        cmp.setup.cmdline(":", {
            mapping = {
                ["<Tab>"] = { c = cmp.mapping.confirm({ select = false }) },
                ["<M-j>"] = {
                    c = function()
                        if cmp.visible() then cmp.select_next_item() else cmp.complete() end
                    end
                },
                ["<M-k>"] = {
                    c = function()
                        if cmp.visible() then cmp.select_prev_item() else cmp.complete() end
                    end
                },
            },
            sources = cmp.config.sources(
                { { name = "path" } },
                { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
            ),
            formatting = { fields = { "abbr" } }
        })
    end
}
