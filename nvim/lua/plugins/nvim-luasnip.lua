local M = {
    src = 'https://github.com/L3MON4D3/LuaSnip',
    version = vim.version.range('*'),
    events = { 'InsertEnter' },
}

M.build = function(ev)
    vim.system({ 'make', 'install_jsregexp' }, { cwd = ev.path }, vim.schedule_wrap(function(out)
        vim.api.nvim_echo({
            { 'LuaSnip',  out.code == 0 and 'DiagnosticOk' or 'DiagnosticError' },
            { ': build ' .. out.code == 0 and 'success!' or 'failed!', '' }
        }, true, { verbose = true })
    end))
end

M.config = function()
    local luasnip = require('luasnip')
    local types = require('luasnip.util.types')

    core.set_keymaps {
        {
            modes = { 'i', 's' }, lhs = '<Tab>',
            rhs = function()
                if luasnip.choice_active() then
                    luasnip.change_choice(1)
                else
                    vim.api.nvim_feedkeys(vim.keycode('<Tab>'), 'n', false)
                end
            end
        },
        {
            modes = { 'i', 's' }, lhs = '<Esc>',
            rhs = function()
                if luasnip.expand_or_jumpable() then
                    luasnip.unlink_current()
                else
                    vim.api.nvim_feedkeys(vim.keycode('<Esc>'), 'n', false)
                end
            end
        }
    }

    luasnip.setup {
        update_events = 'TextChanged,TextChangedI',
        delete_check_events = 'TextChanged',
        ext_opts = {
            [types.snippet] = {
                active = { sign_text = '│', sign_hl_group = 'Keyword' },
            },
            [types.choiceNode] = {
                active = { virt_text = { { '<Tab>', 'Comment' } } },
            },
        }
    }

    require('luasnip.loaders.from_lua').lazy_load { paths = vim.fn.stdpath('config') .. '/snippets' }
end

return M
