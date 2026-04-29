local handles = {}

local init_codecompanion_fidget = function()
    local group = vim.api.nvim_create_augroup('CodeCompanionFidget', { clear = true })

    core.create_autocommand('User', 'CodeCompanionRequestStarted', {
        group = group,
        callback = function(ev)
            handles[ev.data.id] = require('fidget.progress').handle.create {
                title = ' CodeCompanion - ' .. ev.data.interaction,
                lsp_client = { name = ev.data.adapter.formatted_name .. ' ' .. (ev.data.adapter.model or '') }
            }
        end,
    })

    core.create_autocommand('User', 'CodeCompanionRequestFinished', {
        group = group,
        callback = function(ev)
            local h = handles[ev.data.id]
            if h then
                h.title = ' CodeCompanion - ' .. ev.data.interaction
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
        core.set_mode_keymaps('n', {
            ['<Leader>a'] = require('codecompanion').toggle,
        })

        init_codecompanion_fidget()

        require('codecompanion').setup {
            opts = { language = 'Chinese', log_level = 'ERROR' },
            display = {
                chat = { window = { border = 'rounded' } },
                cli  = { window = { opts = { number = false, signcolumn = 'no' } } },
            },
            interactions = {
                inline = {
                    adapter = { name = 'copilot', model = 'gpt-5.3-codex' }
                },
                chat = {
                    adapter = { name = 'copilot', model = 'gpt-5.3-codex' },
                    keymaps = {
                        send  = { modes = { n = '<C-CR>', i = '<C-CR>' } },
                        close = { modes = { n = '<Nop>',  i = '<Nop>'  } },
                    },
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
