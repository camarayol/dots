local M = {
    src     = 'https://www.github.com/camarayol/codecompanion.nvim',
    version = 'camarayol',
    depends = {
        'https://github.com/saghen/blink.cmp',
        'https://www.github.com/nvim-lua/plenary.nvim',
        'https://github.com/nvim-treesitter/nvim-treesitter',
    },
    events  = 'CmdUndefined',
    pattern = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
}

M.option = function()
    core.sk('n', '<Leader>c', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'CodeCompanionChat Toggle' })
    core.sk('x', '<Leader>c', '<Cmd>CodeCompanionChat Add<CR>',    { desc = 'CodeCompanionChat Add' })
end

M.config = function()
    local adapters = require('codecompanion.adapters')

    require('codecompanion').setup {
        opts = { language = 'Chinese' },
        display = {
            action_palette = { provider = 'snacks' },
            chat = {
                window = { buflisted = false, layout = 'vertical', position = 'right', }
            }
        },
        interactions = {
            chat = {
                opts = { completion_provider = 'blink' },
                keymaps = {
                    close = { modes = { n = '<Leader>q', i = '<Nop>' } },
                    stop  = { modes = { n = '<C-c>' } },
                },
                sessions = { enabled = true, autosave = false, continuous_save = true },
                tools = {
                    opts = { approval_mode = "yolo" },
                    web_search = { opts = { adapter = 'tavily' } },
                },
                adapter = 'pi' -- pi agent (rpc adapter)
            },
        },
    }

    local group = vim.api.nvim_create_augroup('core.CodeCompanionNotifier', { clear = true })

    vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionRequest*',
        group = group,
        callback = function(ev)
            local finished = false
            local level    = vim.log.levels.INFO
            local message  = string.format('%s: ', ev.data.adapter.model or 'unknown')

            if ev.match == 'CodeCompanionRequestStarted' then
                level   = vim.log.levels.DEBUG
                message = message .. 'waiting ...'
            elseif ev.match == 'CodeCompanionRequestStreaming' then
                level   = vim.log.levels.WARN
                message = message .. 'working ...'
            elseif ev.match == 'CodeCompanionRequestFinished' then
                finished = true
                level    = vim.log.levels.INFO
                message  = message .. 'finished!'
            end

            vim.notify(message, level, {
                id      = ev.data.id,
                icon    = '',
                title   = string.format(' CodeCompanion(%s)', ev.data.adapter.formatted_name),
                timeout = finished and 3000 or false,
                history = finished
            })
        end
    })

    vim.api.nvim_create_autocmd('User', {
        pattern = 'CodeCompanionChatClosed',
        group = group,
        callback = function(ev)
            vim.notify('CodeCompanionChatClosed', vim.log.levels.INFO, {
                id      = ev.data.id,
                icon    = '',
                title   = ' CodeCompanion',
                timeout = 3000,
                history = false
            })
        end
    })
end

return M
