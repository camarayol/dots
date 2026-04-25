local M = {
    src = 'https://github.com/L3MON4D3/LuaSnip'
}

M.hooks = function(ev)
    vim.notify('[luasnip] building ...')
    vim.system({ 'make', 'install_jsregexp' }, { cwd = ev.path }, vim.schedule_wrap(function(out)
        if out.code == 0 then
            vim.notify('[luasnip] build success!')
        else
            vim.notify('[luasnip] build failed! ' .. out.stderr, vim.log.levels.WARN)
        end
    end))
end

M.config = function()
    require('luasnip').setup {
        update_events = 'TextChanged,TextChangedI',
        delete_check_events = 'TextChanged',
    }

    require("luasnip.loaders.from_lua").lazy_load {
        paths = vim.fn.stdpath('config') .. '/snippets'
    }
end

return M
