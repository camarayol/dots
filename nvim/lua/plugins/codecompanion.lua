local handles = {}

local init_codecompanion_fidget = function()
    local group = vim.api.nvim_create_augroup('CodeCompanionFidget', { clear = true })

    core.create_autocommand('User', 'CodeCompanionRequestStarted', {
        group = group,
        callback = function(ev)
            handles[ev.data.id] = require('fidget.progress').handle.create {
                title = '  CodeCompanion - ' .. ev.data.interaction,
                lsp_client = { name = ev.data.adapter.formatted_name .. ' ' .. (ev.data.adapter.model or '') }
            }
        end,
    })

    core.create_autocommand('User', 'CodeCompanionRequestFinished', {
        group = group,
        callback = function(ev)
            local h = handles[ev.data.id]
            if h then
                h.title = '  CodeCompanion - ' .. ev.data.interaction
                h.message = ev.data.status
                h:finish()
                handles[ev.data.id] = nil
            end
        end,
    })
end

return {
    src = 'https://github.com/olimorris/codecompanion.nvim',
    depends = {
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/j-hui/fidget.nvim',
    },
    config = function()
        init_codecompanion_fidget()

        require('codecompanion').setup {
            opts = { log_level = 'ERROR' },
            display = {
                cli = { window = { opts = { number = false, signcolumn = "no" } } },
            },
            interactions = {
                chat = {
                    adapter = { name = 'copilot', model = 'gpt-5.3-codex' },
                },
                inline = {
                    adapter = { name = 'copilot', model = 'gpt-5.3-codex' },
                },
                cli = {
                    agent = 'opencode',
                    agents = {
                        opencode = { cmd = 'opencode', args = { '--port' }, description = 'OpenCode', provider = 'terminal' }
                    }
                },
            }
        }
    end
}
