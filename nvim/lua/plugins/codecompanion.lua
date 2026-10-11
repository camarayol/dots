local M = {
    src     = 'https://www.github.com/olimorris/codecompanion.nvim',
    depends = {
        'https://github.com/saghen/blink.cmp',
        'https://www.github.com/nvim-lua/plenary.nvim',
        'https://github.com/nvim-treesitter/nvim-treesitter',
    },
    events  = 'CmdUndefined',
    pattern = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
}

M.option = function()
    core.sk('n', '<Leader>c', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'CodeCompanion Chat' })
    core.sk('x', '<Leader>c', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'CodeCompanion Chat' })
end

M.config = function()
    local adapters = require('codecompanion.adapters')

    require('codecompanion').setup {
        opts = { language = 'Chinese' },
        display = {
            action_palette = {
                provider = 'snacks'
            },
            chat = {
                -- show_settings = true,
                window = {
                    layout    = 'buffer',
                    buflisted = 'true',
                    position  = 'right'
                }
            }
        },
        interactions = {
            chat = {
                opts = { completion_provider = 'blink' },
                sessions = { enabled = true, autosave = true, continuous_save = true },
                tools = {
                    opts = {
                        approval_mode = "yolo"
                    },
                    ['web_search'] = { opts = { adapter = 'tavily' } },
                },
                adapter = 'opencode'
            },
        },
        adapters = {
            acp = {
                opencode = adapters.extend('opencode', {
                    defaults = {
                        session_config_options = {
                            model = 'opencode/mimo-v2.6-flash-free',
                        },
                    },
                }),
            },
            http = {
                ['copilot'] = adapters.extend('copilot', {
                    schema = { model = { default = 'gpt-4.1' } },
                }),
                ['openai-codex'] = adapters.extend('openai_responses', {
                    name           = 'openai-codex',
                    formatted_name = 'ChatGPT Codex',
                    url            = 'https://chatgpt.com/backend-api/codex/responses',
                    env            = { api_key = 'OPENAI_API_KEY', account_id = 'OPENAI_ACCOUNT_ID' },
                    schema         = { model = { default = 'gpt-5.5' }, },
                }),
                ['opencode-zen'] = adapters.extend('openai_compatible', {
                    name           = 'opencode-zen',
                    formatted_name = 'OpenCode Zen',
                    env            = { url = 'https://opencode.ai/zen', api_key = 'OPENCODE_API_KEY' },
                    schema         = { model = { default = 'deepseek-v4.1-flash' } }
                })
            },
        }
    }


    vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequest*',
        group = vim.api.nvim_create_augroup('core.CodeCompanionNotifier', { clear = true }),
        callback = function(ev)
            local message = string.format('%s(%s)', ev.data.adapter.formatted_name, ev.data.adapter.model or 'unknow')

            local finished = false

            if ev.match == 'CodeCompanionRequestStarted' then
                message = message .. ' Requesting ...'
            elseif ev.match == 'CodeCompanionRequestStreaming' then
                message = message .. ' Processing ...'
            elseif ev.match == 'CodeCompanionRequestFinished' then
                finished = true
                message = message .. ' Finished!'
            end

            vim.notify(message, vim.log.levels.INFO, {
                id      = ev.data.id,
                icon    = '',
                title   = string.format(' CodeCompanion(%s)', ev.data.interaction),
                timeout = finished and 3000 or false,
                history = finished
            })
        end
    })
end

return M
