local specs = {}
local options = {}

local group = vim.api.nvim_create_augroup('core.vimpack.changed', { clear = true })
vim.api.nvim_create_autocmd('PackChanged', {
    group = group,
    callback = function(ev)
        if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end

        if not ev.data.active then
            pcall(vim.cmd.packadd, ev.data.spec.name)
        end

        if type(options[ev.data.spec.src].hooks) == 'function' then
            pcall(options[ev.data.spec.src].hooks, { path = ev.data.path })
        end
    end,
})

vim.api.nvim_create_user_command('PackUpdate', function(opts)
    local s = (#opts.fargs > 0) and opts.fargs or nil
    vim.pack.update(s, { force = opts.bang })
end, { bang = true, nargs = '*', complete = 'packadd', desc = '[NvimPack] update plugins' })

vim.api.nvim_create_user_command('PackOfflineUpdate', function(opts)
    local s = (#opts.fargs > 0) and opts.fargs or nil
    vim.pack.update(s, { force = opts.bang, offline = true })
end, { bang = true, nargs = '*', complete = 'packadd', desc = '[NvimPack] update plugins offline' })

vim.api.nvim_create_user_command('PackClean', function()
    local s = vim.iter(vim.pack.get())
        :filter(function(x) return not x.active end)
        :map(function(x) return x.spec.name end)
        :totable()

    if #s == 0 then return end

    local answer = vim.fn.confirm(
        'Delete inactive plugins?\n' .. table.concat(s, '\n'),
        '&Yes\n&No',
        2
    )
    if answer == 1 then
        vim.pack.del(s, { force = false })
    end
end, { nargs = '*', complete = 'packadd', desc = '[NvimPack] remove inactive plugins' })

local enqueue_specs = function(s)
    if type(s.src) ~= 'string' or s.src == '' then return end

    if options[s.src] == nil then
        table.insert(specs, { src = s.src, name = s.name, version = s.version })
        options[s.src] = s
    else
        options[s.src] = vim.tbl_extend('force', options[s.src], s)
    end
end

local function parse_specs(s)
    if type(s) ~= 'string' and type(s) ~= 'table' then return end

    if type(s) == 'string' then
        return enqueue_specs { src = s }
    end

    if type(s.depends) == 'string' or type(s.depends) == 'table' then
        local depends = type(s.depends) == 'table' and s.depends or { src = s.depends }
        for _, deps in ipairs(depends) do
            parse_specs(deps)
        end
    end

    enqueue_specs(s)
end

return vim.schedule_wrap(function(spec)
    for _, s in ipairs(spec) do
        parse_specs(s)
    end

    vim.pack.add(specs)

    for _, s in pairs(options) do
        if type(s.config) == 'function' then
            pcall(s.config)
        end
    end
end)
