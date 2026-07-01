local M = {
    src = 'https://github.com/yetone/avante.nvim',
    depends = {
        'https://github.com/nvim-lua/plenary.nvim',
        'https://github.com/MunifTanjim/nui.nvim',
    },
}

M.build = function(ev)
    local cmd = vim.fn.has('win32')
        and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false' or 'make'

    vim.system(vim.split(cmd, ' '), { cwd = ev.path }, function(res)
        if res.code ~= 0 then
            vim.notify('[avante.nvim] build failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
        end
    end)
end

-- https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
M.config = function()
    require('avante').setup {
        provider = 'opencode-zen',
        providers = {
            ['opencode-zen'] = {
                __inherited_from = 'openai',
                endpoint         = 'https://opencode.ai/zen/v1',
                model            = 'deepseek-v4-flash-free',
                api_key_name     = 'OPENCODE_API_KEY',
            }
        },
        acp_providers = {
            ['pi-acp'] = {
                command = vim.fn.has('win32') and 'pi-acp.cmd' or 'pi-acp',
            },
        },
        dual_boost = { enabled = false },
        behaviour = { enable_token_counting = false, auto_add_current_file = false },
        mappings = {
            ask      = '<leader>aa',
            new_ask  = '<leader>an',
            zen_mode = '<leader>az',
            edit     = '<leader>ae',
            refresh  = '<leader>ar',
            focus    = '<leader>af',
            stop     = '<leader>aS',
            cancel   = { normal = '<C-c>', insert = '<C-c>' },
            toggle   = { default = '<leader>at', debug = '<leader>ad', selection = '<leader>aC', suggestion = '<leader>as', repomap = '<leader>aR' },
            sidebar  = {
                next_prompt = ']]',
                prev_prompt = '[[',
                close = 'q',
                close_from_input = { normal = 'q' },
                toggle_code_window = 'z',
                toggle_code_window_from_input = { normal = 'z' }
            },
            files    = { add_current = '<leader>ac', add_all_buffers = '<leader>aB' },
        },
        windows = {
            wrap = true,
            edit = { border = 'rounded' },
            sidebar_header = { enabled = false, include_model = false },
        },
    }
end

return M
