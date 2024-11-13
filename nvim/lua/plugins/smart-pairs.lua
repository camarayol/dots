return {
    source = "https://github.com/ZhiyuanLck/smart-pairs",
    config = function()
        require("pairs"):setup {
            pairs = {
                ['*'] = {
                    { '(', ')' },
                    { '[', ']' },
                    { '{', '}' },
                    { "'", "'" },
                    { '"', '"' },
                },
                markdown = {
                    { '*', '*' },
                    { '`', '`', { triplet = true } },
                },
            },

            --[[
                Scenes like this:
                    {
                        str = "Hello World"
                        |
                    }
                Default press <bs>:
                    {
                        str = "Hello World"|
                    }
                Add 'delete.empty_line.text_bracket.one.strategy = "leave_one_start"' fix into:
                    {
                        str = "Hello World"
                    |
                    }
            ]]
            delete = {
                empty_line = {
                    bracket_text = { one = { strategy = "leave_one_start", } },
                    text_bracket = { one = { strategy = "leave_one_start", } },
                }
            },
            enter = {
                enable_mapping = true,
                enable_cond    = true,
                before_hook    = function()
                    -- https://github.com/gaoDean/autolist.nvim/issues/77
                    local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
                    if filetype == "txt" or filetype == "markdown" then
                        vim.loop.new_timer():start(0, 0, vim.schedule_wrap(function()
                            require("autolist").new_bullet()
                        end))
                    end
                end
            },
        }

        MiniDeps.later_add {
            source = "https://github.com/gaoDean/autolist.nvim",
            config = function()
                Core.createAutoCommand("InsertEnter", { "*.txt", "*.md" }, function()
                    require("autolist").setup {}
                    Core.setKeyMaps {
                        { "n", "o", "o<Cmd>AutolistNewBullet<CR>" },
                        { "n", "O", "O<Cmd>AutolistNewBulletBefore<CR>" },
                    }
                end)
            end
        }
    end
}
