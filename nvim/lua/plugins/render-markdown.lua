return {
    src = "https://github.com/MeanderingProgrammer/render-markdown.nvim",
    depends = {
        'https://github.com/nvim-tree/nvim-web-devicons',
    },
    config = function()
        core.nvim_set_highlights {
            ['RenderMarkdownH1Bg']       = { fg = '#D19A66', bg = 'none' },
            ['RenderMarkdownH2Bg']       = { fg = '#D19A66', bg = 'none' },
            ['RenderMarkdownH3Bg']       = { fg = '#D19A66', bg = 'none' },
            ['RenderMarkdownH4Bg']       = { fg = '#D19A66', bg = 'none' },
            ['RenderMarkdownH6Bg']       = { fg = '#D19A66', bg = 'none' },
            ['RenderMarkdownH5Bg']       = { fg = '#D19A66', bg = 'none' },
            ["RenderMarkdownCode"]       = { fg = 'none', bg = '#1f2228' },
            ["RenderMarkdownCodeInline"] = { fg = 'none', bg = '#1f2228' },
        }

        require('render-markdown').setup({
            -- Whether markdown should be rendered by default.
            enabled = true,
            -- Vim modes that will show a rendered view of the markdown file, :h mode(), for all enabled
            -- components. Individual components can be enabled for other modes. Remaining modes will be
            -- unaffected by this plugin.
            render_modes = { 'n', 'c', 't' },
            -- Milliseconds that must pass before updating marks, updates occur.
            -- within the context of the visible window, not the entire buffer.
            debounce = 100,
            -- Pre configured settings that will attempt to mimic various target user experiences.
            -- User provided settings will take precedence.
            -- | obsidian | mimic Obsidian UI                                          |
            -- | lazy     | will attempt to stay up to date with LazyVim configuration |
            -- | none     | does nothing                                               |
            preset = 'none',
            -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'.
            -- Only intended to be used for plugin development / debugging.
            log_level = 'error',
            -- Print runtime of main update method.
            -- Only intended to be used for plugin development / debugging.
            log_runtime = false,
            -- Filetypes this plugin will run on.
            file_types = { 'markdown', 'codecompanion' },
            -- Maximum file size (in MB) that this plugin will attempt to render.
            -- File larger than this will effectively be ignored.
            max_file_size = 10.0,
            -- Takes buffer as input, if it returns true this plugin will not attach to the buffer.
            ignore = function()
                return false
            end,
            -- Whether markdown should be rendered when nested inside markdown, i.e. markdown code block
            -- inside markdown file.
            nested = true,
            -- Additional events that will trigger this plugin's render loop.
            change_events = {},
            -- Whether the treesitter highlighter should be restarted after this plugin attaches to its
            -- first buffer for the first time. May be necessary if this plugin is lazy loaded to clear
            -- highlights that have been dynamically disabled.
            restart_highlighter = false,
            injections = {
                -- Out of the box language injections for known filetypes that allow markdown to be interpreted
                -- in specified locations, see :h treesitter-language-injections.
                -- Set enabled to false in order to disable.

                gitcommit = {
                    enabled = true,
                    query = [[
                ((message) @injection.content
                    (#set! injection.combined)
                    (#set! injection.include-children)
                    (#set! injection.language "markdown"))
            ]],
                },
            },
            patterns = {
                markdown = {
                    disable = true,
                    directives = {
                        { id = 17, name = 'conceal_lines' },
                        { id = 18, name = 'conceal_lines' },
                    },
                },
            },
            anti_conceal = { enabled = false, },
            padding = {
                -- Highlight to use when adding whitespace, should match background.
                highlight = 'Normal',
            },
            latex = { enabled = false, },
            heading = { enabled = false },
            paragraph = {
                -- Useful context to have when evaluating values.
                -- | text | text value of the node |

                -- Turn on / off paragraph rendering.
                enabled = true,
                -- Additional modes to render paragraphs.
                render_modes = false,
                -- Amount of margin to add to the left of paragraphs.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                -- Output is evaluated depending on the type.
                -- | function | `value(context)` |
                -- | number   | `value`          |
                left_margin = 0,
                -- Amount of padding to add to the first line of each paragraph.
                -- Output is evaluated using the same logic as 'left_margin'.
                indent = 0,
                -- Minimum width to use for paragraphs.
                min_width = 0,
            },
            code = {
                -- Turn on / off code block & inline code rendering.
                enabled = true,
                -- Additional modes to render code blocks.
                render_modes = false,
                -- Turn on / off sign column related rendering.
                sign = true,
                -- Whether to conceal nodes at the top and bottom of code blocks.
                conceal_delimiters = true,
                -- Turn on / off language heading related rendering.
                language = true,
                -- Determines where language icon is rendered.
                -- | center | center of code block |
                -- | right  | right of code block  |
                -- | left   | left of code block   |
                position = 'left',
                -- Whether to include the language icon above code blocks.
                language_icon = true,
                -- Whether to include the language name above code blocks.
                language_name = true,
                -- Whether to include the language info above code blocks.
                language_info = true,
                -- Amount of padding to add around the language.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                language_pad = 0,
                -- A list of language names for which rendering will be disabled.
                disable = {},
                -- A list of language names for which background highlighting will be disabled.
                -- Likely because that language has background highlights itself.
                -- Use a boolean to make behavior apply to all languages.
                -- Borders above & below blocks will continue to be rendered.
                disable_background = { 'diff' },
                -- Width of the code block background.
                -- | block | width of the code block  |
                -- | full  | full width of the window |
                width = 'full',
                -- Amount of margin to add to the left of code blocks.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                -- Margin available space is computed after accounting for padding.
                left_margin = 0,
                -- Amount of padding to add to the left of code blocks.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                left_pad = 0,
                -- Amount of padding to add to the right of code blocks when width is 'block'.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                right_pad = 0,
                -- Minimum width to use for code blocks when width is 'block'.
                min_width = 0,
                -- Determines how the top / bottom of code block are rendered.
                -- | none  | do not render a border                               |
                -- | thick | use the same highlight as the code body              |
                -- | thin  | when lines are empty overlay the above & below icons |
                -- | hide  | conceal lines unless language name or icon is added  |
                border = 'thin',
                -- Used above code blocks to fill remaining space around language.
                language_border = '█',
                -- Added to the left of language.
                language_left = '',
                -- Added to the right of language.
                language_right = '',
                -- Used above code blocks for thin border.
                above = '▄',
                -- Used below code blocks for thin border.
                below = '▀',
                -- Turn on / off inline code related rendering.
                inline = true,
                -- Icon to add to the left of inline code.
                inline_left = '',
                -- Icon to add to the right of inline code.
                inline_right = '',
                -- Padding to add to the left & right of inline code.
                inline_pad = 0,
                -- Priority to assign to code background highlight.
                priority = 140,
                -- Highlight for code blocks.
                highlight = 'RenderMarkdownCode',
                -- Highlight for code info section, after the language.
                highlight_info = 'RenderMarkdownCodeInfo',
                -- Highlight for language, overrides icon provider value.
                highlight_language = nil,
                -- Highlight for border, use false to add no highlight.
                highlight_border = 'RenderMarkdownCodeBorder',
                -- Highlight for language, used if icon provider does not have a value.
                highlight_fallback = 'RenderMarkdownCodeFallback',
                -- Highlight for inline code.
                highlight_inline = 'RenderMarkdownCodeInline',
                -- Highlight for inline code left icon, default to reverse of highlight_inline.
                highlight_inline_left = nil,
                -- Highlight for inline code right icon, default to reverse of highlight_inline.
                highlight_inline_right = nil,
                -- Determines how code blocks & inline code are rendered.
                -- | none     | { enabled = false }                           |
                -- | normal   | { language = false }                          |
                -- | language | { disable_background = true, inline = false } |
                -- | full     | uses all default values                       |
                style = 'full',
            },
            dash = {
                -- Useful context to have when evaluating values.
                -- | width | width of the current window |

                -- Turn on / off thematic break rendering.
                enabled = true,
                -- Additional modes to render dash.
                render_modes = false,
                -- Replaces '---'|'***'|'___'|'* * *' of 'thematic_break'.
                -- The icon gets repeated across the window's width.
                icon = '─',
                -- Width of the generated line.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                -- Output is evaluated depending on the type.
                -- | function | `value(context)`    |
                -- | number   | `value`             |
                -- | full     | width of the window |
                width = 'full',
                -- Amount of margin to add to the left of dash.
                -- If a float < 1 is provided it is treated as a percentage of available window space.
                left_margin = 0,
                -- Priority to assign to dash.
                priority = nil,
                -- Highlight for the whole line generated from the icon.
                highlight = 'RenderMarkdownDash',
            },
            document = {
                -- Turn on / off document rendering.
                enabled = true,
                -- Additional modes to render document.
                render_modes = false,
                -- Ability to conceal arbitrary ranges of text based on lua patterns, @see :h lua-patterns.
                -- Relies entirely on user to set patterns that handle their edge cases.
                conceal = {
                    -- Matched ranges will be concealed using character level conceal.
                    char_patterns = {},
                    -- Matched ranges will be concealed using line level conceal.
                    line_patterns = {},
                },
            },
            bullet = { enabled = false },
            checkbox = { enabled = false },
            quote = {
                -- Turn on / off block quote & callout rendering.
                enabled = true,
                -- Additional modes to render quotes.
                render_modes = false,
                -- Replaces '>' of 'block_quote'.
                icon = '▋',
                -- Whether to repeat icon on wrapped lines. Requires neovim >= 0.10. This will obscure text
                -- if incorrectly configured with :h 'showbreak', :h 'breakindent' and :h 'breakindentopt'.
                -- A combination of these that is likely to work follows.
                -- | showbreak      | '  ' (2 spaces)   |
                -- | breakindent    | true              |
                -- | breakindentopt | '' (empty string) |
                -- These are not validated by this plugin. If you want to avoid adding these to your main
                -- configuration then set them in win_options for this plugin.
                repeat_linebreak = false,
                -- Highlight for the quote icon.
                -- If a list is provided output is evaluated by `cycle(value, level)`.
                highlight = {
                    'RenderMarkdownQuote1',
                    'RenderMarkdownQuote2',
                    'RenderMarkdownQuote3',
                    'RenderMarkdownQuote4',
                    'RenderMarkdownQuote5',
                    'RenderMarkdownQuote6',
                },
            },
            pipe_table = {
                -- Turn on / off pipe table rendering.
                enabled = true,
                -- Additional modes to render pipe tables.
                render_modes = false,
                -- Pre configured settings largely for setting table border easier.
                -- | heavy  | use thicker border characters     |
                -- | double | use double line border characters |
                -- | round  | use round border corners          |
                -- | none   | does nothing                      |
                preset = 'none',
                -- Determines how individual cells of a table are rendered.
                -- | overlay | writes completely over the table, removing conceal behavior and highlights |
                -- | raw     | replaces only the '|' characters in each row, leaving the cells unmodified |
                -- | padded  | raw + cells are padded to maximum visual width for each column             |
                -- | trimmed | padded except empty space is subtracted from visual width calculation      |
                cell = 'padded',
                -- Adjust the computed width of table cells using custom logic.
                cell_offset = function()
                    return 0
                end,
                -- Amount of space to put between cell contents and border.
                padding = 1,
                -- Minimum column width to use for padded or trimmed cell.
                min_width = 0,
                -- Characters used to replace table border.
                -- Correspond to top(3), delimiter(3), bottom(3), vertical, & horizontal.
                -- stylua: ignore
                border = {
                    '┌', '┬', '┐',
                    '├', '┼', '┤',
                    '└', '┴', '┘',
                    '│', '─',
                },
                -- Turn on / off top & bottom lines.
                border_enabled = true,
                -- Always use virtual lines for table borders instead of attempting to use empty lines.
                -- Will be automatically enabled if indentation module is enabled.
                border_virtual = false,
                -- Gets placed in delimiter row for each column, position is based on alignment.
                alignment_indicator = '━',
                -- Highlight for table heading, delimiter, and the line above.
                head = 'RenderMarkdownTableHead',
                -- Highlight for everything else, main table rows and the line below.
                row = 'RenderMarkdownTableRow',
                -- Determines how the table as a whole is rendered.
                -- | none   | { enabled = false }        |
                -- | normal | { border_enabled = false } |
                -- | full   | uses all default values    |
                style = 'full',
            },
            callout = {
                -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'.
                -- The key is for healthcheck and to allow users to change its values, value type below.
                -- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
                -- | rendered   | replaces the 'raw' value when rendering                             |
                -- | highlight  | highlight for the 'rendered' text and quote markers                 |
                -- | quote_icon | optional override for quote.icon value for individual callout       |
                -- | category   | optional metadata useful for filtering                              |

                note      = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo', category = 'github' },
                tip       = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess', category = 'github' },
                important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint', category = 'github' },
                warning   = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn', category = 'github' },
                caution   = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError', category = 'github' },
                -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
                abstract  = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
                summary   = { raw = '[!SUMMARY]', rendered = '󰨸 Summary', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
                tldr      = { raw = '[!TLDR]', rendered = '󰨸 Tldr', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
                info      = { raw = '[!INFO]', rendered = '󰋽 Info', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
                todo      = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
                hint      = { raw = '[!HINT]', rendered = '󰌶 Hint', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
                success   = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
                check     = { raw = '[!CHECK]', rendered = '󰄬 Check', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
                done      = { raw = '[!DONE]', rendered = '󰄬 Done', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
                question  = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
                help      = { raw = '[!HELP]', rendered = '󰘥 Help', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
                faq       = { raw = '[!FAQ]', rendered = '󰘥 Faq', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
                attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
                failure   = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError', category = 'obsidian' },
                fail      = { raw = '[!FAIL]', rendered = '󰅖 Fail', highlight = 'RenderMarkdownError', category = 'obsidian' },
                missing   = { raw = '[!MISSING]', rendered = '󰅖 Missing', highlight = 'RenderMarkdownError', category = 'obsidian' },
                danger    = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError', category = 'obsidian' },
                error     = { raw = '[!ERROR]', rendered = '󱐌 Error', highlight = 'RenderMarkdownError', category = 'obsidian' },
                bug       = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError', category = 'obsidian' },
                example   = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint', category = 'obsidian' },
                quote     = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote', category = 'obsidian' },
                cite      = { raw = '[!CITE]', rendered = '󱆨 Cite', highlight = 'RenderMarkdownQuote', category = 'obsidian' },
            },
            link = { enabled = false },
            sign = { enabled = false },
            inline_highlight = {
                -- Mimics Obsidian inline highlights when content is surrounded by double equals.
                -- The equals on both ends are concealed and the inner content is highlighted.

                -- Turn on / off inline highlight rendering.
                enabled = true,
                -- Additional modes to render inline highlights.
                render_modes = false,
                -- Applies to background of surrounded text.
                highlight = 'RenderMarkdownInlineHighlight',
                -- Define custom highlights based on text prefix.
                -- The key is for healthcheck and to allow users to change its values, value type below.
                -- | prefix    | matched against text body, @see :h vim.startswith() |
                -- | highlight | highlight for text body                             |
                custom = {},
            },
            indent = { enabled = false },
            html = { enabled = false },
            win_options = {
                -- Window options to use that change between rendered and raw view.

                -- @see :h 'conceallevel'
                conceallevel = {
                    -- Used when not being rendered, get user setting.
                    default = vim.o.conceallevel,
                    -- Used when being rendered, concealed text is completely hidden.
                    rendered = 3,
                },
                -- @see :h 'concealcursor'
                concealcursor = {
                    -- Used when not being rendered, get user setting.
                    default = vim.o.concealcursor,
                    -- Used when being rendered, show concealed text in all modes.
                    rendered = '',
                },
            },
            overrides = {
                -- More granular configuration mechanism, allows different aspects of buffers to have their own
                -- behavior. Values default to the top level configuration if no override is provided. Supports
                -- the following fields:
                --   enabled, render_modes, debounce, anti_conceal, bullet, callout, checkbox, code, dash,
                --   document, heading, html, indent, inline_highlight, latex, link, padding, paragraph,
                --   pipe_table, quote, sign, win_options, yaml

                -- Override for different buflisted values, @see :h 'buflisted'.
                buflisted = {},
                -- Override for different buftype values, @see :h 'buftype'.
                buftype = {
                    nofile = {
                        render_modes = true,
                        padding = { highlight = 'NormalFloat' },
                        sign = { enabled = false },
                    },
                },
                -- Override for different filetype values, @see :h 'filetype'.
                filetype = {},
                -- Override for preview buffer.
                preview = {
                    render_modes = true,
                },
            },
            custom_handlers = {
                -- Mapping from treesitter language to user defined handlers.
                -- @see [Custom Handlers](doc/custom-handlers.md)
            },
            yaml = {
                -- Turn on / off all yaml rendering.
                enabled = true,
                -- Additional modes to render yaml.
                render_modes = false,
            },
        })
    end
}
