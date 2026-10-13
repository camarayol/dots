local M  = {
    src     = 'https://github.com/camarayol/pi.nvim',
    depends = 'https://github.com/saghen/blink.cmp',
    events  = 'CmdUndefined',
    pattern = { 'Pi', 'PiResume', 'PiSendMention' }
}

M.option = function ()
    core.sk('n', '<Leader>aa', '<Cmd>Pi<CR>',            { desc = 'Pi toggle' })
    core.sk('n', '<Leader>as', '<Cmd>PiSendMention<CR>', { desc = 'Pi send mention' })
    core.sk('n', '<Leader>ar', '<Cmd>PiResume<CR>',      { desc = 'Pi resume' })
    core.sk('v', '<Leader>a',  '<Cmd>PiSendMention<CR>', { desc = 'Pi send mention' })
end

M.config = function()
    local pi = require('pi')

    local blink = require('blink.cmp')
    blink.add_source_provider('pi', { name = 'pi', module = 'pi.completion.blink' })
    blink.add_filetype_source('pi-chat-prompt', 'pi')

    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'pi-chat-prompt', 'pi-chat-history', 'pi-chat-attachments' },
        group = vim.api.nvim_create_augroup('core.Pi', { clear = true }),
        callback = function(ev)
            vim.bo[ev.buf].syntax = 'markdown'
            -- vim.treesitter.start(ev.buf, 'markdown')

            core.sk('n', '<Esc>', pi.toggle_chat, { buf = ev.buf })

            if ev.match == 'pi-chat-prompt' then
                core.sk('n', '<Tab>', pi.focus_chat_history, { buf = ev.buf })
                core.sk('n', '<C-c>', pi.abort, { buf = ev.buf })
            end
        end
    })

    pi.setup {
        cli = { bin = core.hasfeature('win32') and 'pi.cmd' or 'pi', args = {}, },
        spinner = 'classic',
        show_thinking = false,
        expand_startup_details = true,
        timestamp_format = '%Y-%m-%d %H:%M:%S',

        panels = {
            history     = { title = 'π' },
            prompt      = { title = '󰫽󰫿󰫼󰫺󰫽󰬁' },
            attachments = { title = '󰫮󰬁󰬁󰫮󰫰󰫵󰫺󰫲󰫻󰬁󰬀' },
        },

        labels = {
            user_message      = 'request',
            agent_response    = 'response',
            steer_message     = 'stearing',
            system_error      = '󱚟',
            tool              = '󰻂',
            tool_success      = '',
            tool_failure      = '',
            follow_up_message = '',
            thinking          = '',
            compaction        = '',
            attachment        = '',
            attachments       = '',
            error             = '󱚟',
        },

        layout = {
            default = 'side',
            side = {
                position = 'right',
                width = 80,
                panels = {
                    history     = { winbar = true },
                    prompt      = { winbar = true },
                    attachments = { winbar = true },
                },
            },
            float = { width = 0.6, height = 0.8, border = 'rounded' },
        },

        statusline = {
            layout = {
                left  = { 'tokens', 'cache', 'context', 'attention' },
                right = { 'cost', 'thinking', 'model' },
            },
            components = {
                tokens     = { icon = false },
                cache      = { icon = false },
                cost       = { icon = false },
                compaction = { icon = false },
                context    = { icon = false, warn = 70, error = 90 },
                attention  = { icon = false, counter = false },
                model      = { icon = false },
                thinking   = { icon = false },
            },
        },

        diff = {
            icons = { note = '󰆈' },
            context = { base = nil, step = 5 },
            keymap_hints = 'dialog',
            keys = {
                accept         = '<Leader>da',
                reject         = '<Leader>dr',
                edit_note      = '<Leader>dn',
                delete_note    = '<Leader>dx',
                list_notes     = '<Leader>dN',
                expand_context = '<Leader>de',
                shrink_context = '<Leader>ds',
            },
        },

        attention = {
            auto_open_on_prompt_focus = true,
            notify_on_completion = true,
        },

        dialog = {
            border = 'rounded',
            max_width = 0.8,
            max_height = 0.8,
            indicator = '',
            keys = { confirm = nil, cancel = nil, next = nil, prev = nil },
        },

        zen = {
            width = nil,
            keys = {
                toggle = { modes = { 'n' }, 'z' },
                exit   = { modes = { 'n' }, '<Esc>' },
            },
        },

        verbs = { use_defaults = false },

        on_widget = nil,
    }

    core.hl {
        ['PiUserMessageLabel']   = { fg = '#56B6C2', bold = true, dim = true, underline = true },
        ['PiAgentResponseLabel'] = { fg = '#E5C07B', bold = true, dim = true, underline = true },

        ['PiDebugLabel']         = { link = 'Comment' },
        ['PiStartupLabel']       = { link = 'Comment' },
        ['PiStartupErrorLabel']  = { link = 'ErrorMsg' },

        ['PiStartupHint']        = { link = 'Comment' },
        ['PiStartupDetail']      = { link = 'Comment' },
        ['PiStartupError']       = { link = 'Comment' },
        ['PiCompactionLabel']    = { link = 'Comment' },
        ['PiCompactionText']     = { link = 'Comment' },
        ['PiCompactionHint']     = { link = 'Comment' },
        ['PiMessageDateTime']    = { link = 'Comment' },
        ['PiMessageQueueTag']    = { link = 'Comment' },
        ['PiMessageAttachments'] = { link = 'Comment' },
        ['PiPendingQueueLabel']  = { link = 'Comment' },
        ['PiPendingQueueText']   = { link = 'Comment' },
        ['PiThinking']           = { link = 'Comment' },

        ['PiToolBorder']         = { link = 'FloatBorder' },
        ['PiToolHeader']         = { link = 'DiagnosticOk' },
        ['PiToolStatus']         = { link = 'DiagnosticOk' },
        ['PiToolSuccess']        = { link = 'DiagnosticOk' },
        ['PiToolError']          = { link = 'DiagnosticError' },
        ['PiToolCall']           = { link = 'Comment' },
        ['PiToolOutput']         = { link = 'Comment' },
        ['PiToolCollapsed']      = { link = 'Comment' },

        ['PiMention']            = { link = 'Keyword' },
        ['PiCommand']            = { link = 'Comment' },
        ['PiWelcome']            = { link = 'Comment' },
        ['PiWelcomeHint']        = { link = 'Comment' },
        ['PiBusy']               = { link = 'Comment' },
        ['PiBusyTime']           = { link = 'Comment' },
        ['PiWarning']            = { link = 'WarningMsg' },
        ['PiError']              = { link = 'ErrorMsg' },
        ['PiDebug']              = { link = 'Comment' },
    }
end

return M
