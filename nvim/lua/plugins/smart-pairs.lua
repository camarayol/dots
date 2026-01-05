local autolist = function()
    local line = vim.api.nvim_get_current_line()

    local indent, bullet, content = line:match("^(%s*)([-+*])%s*(.*)$")
    if indent and bullet then
        if content == '' then
            return vim.api.nvim_set_current_line('')
        else
            return vim.api.nvim_feedkeys(bullet .. ' ', 'n', true)
        end
    end

    indent, bullet, content = line:match("^(%s*)(%d+)%.%s*(.*)$")
    if indent and bullet then
        if content == '' then
            return vim.api.nvim_set_current_line('')
        else
            return vim.api.nvim_feedkeys(tonumber(bullet) + 1 .. '. ', 'n', true)
        end
    end
end

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
                enable_mapping = true, enable_cond = true,
                after_hook = function()
                    if vim.bo.filetype == 'markdown' or vim.bo.filetype == 'typst' then
                        autolist()
                    end
                end
            }
        }

        Core.createAutoCommand('FileType', { 'markdown', 'typst' }, function()
            Core.setKeyMaps {
                { 'n', 'o', function() vim.fn.feedkeys('o', 'n'); autolist() end, { noremap = true, silent = true } }
            }
        end)
    end
}
