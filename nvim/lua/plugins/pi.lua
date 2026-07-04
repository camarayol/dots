local M = {
    src = 'https://github.com/camarayol/pi.nvim'
}

M.config = function()
    local pi = require('pi')

    core.set_keymaps('n', {
        ['<Leader>aa'] = {
            desc = '[Pi] toggle',
            callback = function() vim.cmd('Pi') end
        },
        ['<Leader>ar'] = {
            desc = '[Pi] resume',
            callback = function() vim.cmd('PiResume') end
        },
    })

    core.set_keymaps('v', {
        ['<Leader>a'] = {
            desc = '[Pi] send mention',
            callback = function() vim.cmd('PiSendMention') end
        },
    })

    core.create_autocommand('FileType', {
        pattern = { 'pi-chat-prompt', 'pi-chat-history', 'pi-chat-attachments' },
        callback = function(ev)
            vim.bo[ev.buf].syntax = ''
            vim.treesitter.start(ev.buf, 'markdown')

            core.set_keymaps('n', {
                ['<Esc>'] = { buf = ev.buf, callback = pi.toggle_chat },
            })

            if ev.match == 'pi-chat-prompt' then
                core.set_keymaps('n', {
                    ['<Tab>'] = { buf = ev.buf, callback = pi.focus_chat_history },
                    ['<C-c>'] = { buf = ev.buf, callback = pi.abort }
                })
            end
        end
    })

    pi.setup {
        -- pi CLI invocation. Extra args are inserted before `--mode rpc`.
        -- Args that conflict with RPC mode (`--mode`, `--print`, `--help`, etc.) are ignored.
        cli = {
            bin = core.hasfeature('win32') and 'pi.cmd' or 'pi',
            args = {},
        },
        -- Enable RPC debug logging to `stdpath('log')/pi/<session>/rpc.log`.
        debug = false,
        -- Override the π agent directory used for session lookup.
        -- Defaults to $PI_CODING_AGENT_DIR or ~/.pi/agent.
        agent_dir = nil,
        -- Preferred models for cycling and :PiSelectModel dialog.
        -- Each entry is either a string (exact ID) or a table:
        --   { match = 'opus', latest = true }
        --   { match = 'gpt-5.3-codex', exact = true } or just 'gpt-5.3-codex'
        models = nil,
        -- Spinner shown while the agent is working.
        -- Preset name ('classic'|'robot'), array of frames (strings), or
        -- { refresh_rate = ms, frames = { ... } }.
        spinner = 'robot',
        -- Show thinking blocks by default.
        show_thinking = false,
        -- Default expand/collapse state for the startup block
        -- (skills, extensions, startup announcements).
        expand_startup_details = true,

        -- Chat panels
        panels = {
            -- Titles shown in panel winbars.
            history = { title = 'π' },
            prompt = { title = '󰫽󰫿󰫼󰫺󰫽󰬁' },
            attachments = { title = '󰫮󰬁󰬁󰫮󰫰󰫵󰫺󰫲󰫻󰬁󰬀' },
        },

        -- Inline labels rendered in the chat history.
        labels = {
            user_message = '',
            agent_response = '󰚩',
            system_error = '󱚟',
            tool = '',
            tool_success = '',
            tool_failure = '',
            steer_message = '󰾘',
            follow_up_message = '󱇼',
            thinking = '󰟶',
            compaction = '󰏗',
            attachment = '',
            attachments = '',
            error = '󰘨 󱚟 󱔁 ',
        },

        -- Tool glyphs used by pi.nvim tool renderer (mapped to pi.ui.chat.tools internals).
        tool_glyphs = {
            top = '',
            mid = '   ',
            sep = '   ',
            bot = '',
        },

        -- Chat layout
        layout = {
            -- Default layout when opening the chat: 'side' or 'float'.
            default = 'side',
            side = {
                -- Side panel position: 'right' or 'bottom'.
                position = 'right',
                -- Width in columns when position is 'right'.
                width = 80,
                panels = {
                    -- Show winbars on each panel in side layout.
                    history = { winbar = true },
                    prompt = { winbar = true },
                    attachments = { winbar = true },
                },
            },
            float = {
                -- Width/height: fraction (<1) or columns/lines (>=1).
                width = 0.6,
                height = 0.8,
                border = 'rounded',
            },
        },

        -- Status line in the prompt window
        statusline = {
            -- Components rendered in the prompt statusline.
            -- Entries are built-in component names, literal separators,
            -- or custom component functions.
            layout = {
                left  = { 'tokens', 'cache', 'context', 'attention' },
                right = { 'cost', 'thinking', 'model' },
            },
            components = {
                tokens = { icon = false },
                cache = { icon = false },
                cost = { icon = false },
                compaction = { icon = false },
                context = { icon = false, warn = 70, error = 90 }, -- `warn`/`error` are percentages of context window used.
                attention = { icon = false, counter = false },
                model = { icon = false },
                thinking = { icon = false },
            },
        },

        -- Diff review
        diff = {
            icons = {
                -- Icon/sign used for diff review notes. Set to false to omit it.
                note = '󰆈',
            },
            -- Visible context around each hunk.
            context = {
                -- Initial visible context around each hunk.
                -- nil means use current 'diffopt' context.
                base = nil,
                -- Lines added/removed by expand/shrink actions.
                step = 5,
            },
            -- How to show diff review keymap hints:
            -- 'dialog' or true (default): show compact '?=keymaps' and open an informational keymap dialog with ?.
            -- 'winbar': show full inline winbar hints.
            -- false: hide hints and bind no help key.
            keymap_hints = 'dialog',
            -- Keymaps active inside the diff review tab.
            keys = {
                accept = '<Leader>da',
                reject = '<Leader>dr',
                edit_note = '<Leader>dn',
                delete_note = '<Leader>dx',
                list_notes = '<Leader>dN',
                expand_context = '<Leader>de',
                shrink_context = '<Leader>ds',
            },
        },

        -- Attention queue for user-input requests (confirms, selects, etc.)
        attention = {
            -- Auto-open the next pending attention request when the
            -- current tab's prompt is refocused and empty.
            -- If false, needs :PiAttention command to pull what's pending.
            auto_open_on_prompt_focus = true,
            -- Notify when the agent finishes a turn and the prompt is not focused.
            notify_on_completion = true,
        },

        -- Selects, confirmation dialogs
        dialog = {
            border = 'rounded',
            -- Max size: fraction (<1) or columns/lines (>=1).
            max_width = 0.8,
            max_height = 0.8,
            -- Sign text for the selected item.
            indicator = '▸',
            keys = {
                -- Optional dialog keymaps; nil leaves built-in defaults in place.
                confirm = nil,
                cancel = nil,
                next = nil,
                prev = nil,
            },
        },

        -- Zen mode for composing larger prompts
        zen = {
            -- Zen stack width in columns. nil => full width.
            width = nil,
            keys = {
                -- Key to enter/exit zen mode.
                toggle = { modes = { 'n' }, 'z' },
                -- Additional keys that only exit zen mode.
                exit   = { modes = { 'n' }, '<Esc>' },
            },
        },

        -- Verb pairs for status messages, picked randomly per run.
        verbs = {
            -- When true, user pairs are appended to the built-in list;
            -- when false, they replace it.
            use_defaults = true,
            pairs = {
                { 'Rewriting in Rust',  'Rewrote in Rust' },
                { 'Making no mistakes', 'Made no mistakes' },
                -- ... and more built-in pairs
            },
        },

        -- Extension setWidget hook. Return a custom block to render inline
        -- in history, or nil to ignore. Not called for `:startup` widgets.
        on_widget = nil,
    }
end

return M
