return {
    source = "https://github.com/folke/flash.nvim",
    config = function()
        Core.setKeyMaps {
            { { "n", "x", "o" }, "<leader>j", function() require("flash").jump() end, { desc = "Flash" } }
        }
        require("flash").setup {
            labels = "asdfghjklqwertyuiopzxcvbnm",
            search = {
                -- search/jump in all windows
                multi_window = true,
                -- search direction
                forward = true,
                -- when `false`, find only matches in the given direction
                wrap = true,
                -- Each mode will take ignorecase and smartcase into account.
                mode = "fuzzy", ---@type "exact" | "search" | "fuzzy"
                -- behave like `incsearch`
                incremental = false,
                -- Excluded filetypes and custom window filters
                exclude = {
                    "notify",
                    "cmp_menu",
                    "noice",
                    "flash_prompt",
                    function(win)
                        -- exclude non-focusable windows
                        return not vim.api.nvim_win_get_config(win).focusable
                    end,
                },
                -- Optional trigger character that needs to be typed before
                -- a jump label can be used. It's NOT recommended to set this,
                -- unless you know what you're doing
                trigger = "",
                -- max pattern length. If the pattern length is equal to this
                -- labels will no longer be skipped. When it exceeds this length
                -- it will either end in a jump or terminate the search
                max_length = false, ---@type number|false
            },
            jump = {
                -- save location in the jumplist
                jumplist = true,
                -- jump position
                pos = "end", ---@type "start" | "end" | "range"
                -- add pattern to search history
                history = false,
                -- add pattern to search register
                register = false,
                -- clear highlight after jump
                nohlsearch = false,
                -- automatically jump when there is only one match
                autojump = false,
                -- You can force inclusive/exclusive jumps by setting the
                -- `inclusive` option. By default it will be automatically
                -- set based on the mode.
                inclusive = nil, ---@type boolean?
                -- jump position offset. Not used for range jumps.
                -- 0: default
                -- 1: when pos == "end" and pos < current position
                offset = nil, ---@type number
            },
            label = {
                -- allow uppercase labels
                uppercase = false,
                -- add any labels with the correct case here, that you want to exclude
                exclude = "",
                -- add a label for the first match in the current window.
                -- you can always jump to the first match with `<CR>`
                current = true,
                -- show the label after the match
                after = true, ---@type boolean|number[]
                -- show the label before the match
                before = false, ---@type boolean|number[]
                -- position of the label extmark
                style = "inline", ---@type "eol" | "overlay" | "right_align" | "inline"
                -- flash tries to re-use labels that were already assigned to a position,
                -- when typing more characters. By default only lower-case labels are re-used.
                reuse = "lowercase", ---@type "lowercase" | "all" | "none"
                -- for the current window, label targets closer to the cursor first
                distance = true,
                -- minimum pattern length to show labels
                -- Ignored for custom labelers.
                min_pattern_length = 0,
                -- Enable this to use rainbow colors to highlight labels
                -- Can be useful for visualizing Treesitter ranges.
                rainbow = {
                    enabled = true,
                    -- number between 1 and 9
                    shade = 5,
                },
                format = function(opts)
                    return { { opts.match.label, opts.hl_group } }
                end,
            },
            highlight = {
                -- show a backdrop with hl FlashBackdrop
                backdrop = true,
                -- Highlight the search matches
                matches = true,
                -- extmark priority
                priority = 5000,
                groups = {
                    match = "FlashMatch",
                    current = "FlashCurrent",
                    backdrop = "FlashBackdrop",
                    label = "FlashLabel",
                },
            },
            modes = {
                search = { enabled = false },
                char = { enabled = false },
            },
            -- options for the floating window that shows the prompt,
            -- for regular jumps
            prompt = {
                enabled = true,
                prefix = { { "⚡", "FlashPromptIcon" } },
                win_config = {
                    relative = "editor",
                    width = 1, -- when <=1 it's a percentage of the editor width
                    height = 1,
                    row = -1,  -- when negative it's an offset from the bottom
                    col = 0,   -- when negative it's an offset from the right
                    zindex = 1000,
                },
            },
        }
    end
}
