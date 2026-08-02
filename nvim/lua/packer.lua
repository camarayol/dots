-- Update plugins
vim.api.nvim_create_user_command('PackUpdate', function(opts)
    local names = #opts.fargs > 0 and opts.fargs or nil
    vim.pack.update(names, { force = opts.bang })
end, { bang = true, nargs = '*', complete = 'packadd', desc = 'NvimPack update plugins' })

-- Update plugins offline
vim.api.nvim_create_user_command('PackOfflineUpdate', function(opts)
    local names = #opts.fargs > 0 and opts.fargs or nil
    vim.pack.update(names, { force = opts.bang, offline = true })
end, { bang = true, nargs = '*', complete = 'packadd', desc = 'NvimPack update plugins offline' })

-- Build plugins
vim.api.nvim_create_user_command('PackBuild', function()
    for i, plugin in ipairs(vim.pack.get()) do
        if type(plugin.spec.data) == 'table' and type(plugin.spec.data.build) == 'function'
        then
            pcall(plugin.spec.data.build, plugin.path)
        end
    end
end, { desc = 'NvimPack run build callbacks for all plugins' })

-- Delete plugins
vim.api.nvim_create_user_command('PackClean', function()
    local specs = vim.iter(vim.pack.get())
        :filter(function(x) return not x.active end)
        :map(function(x) return x.spec.name end)
        :totable()

    if #specs == 0 then return end

    local command = 'Delete: ' .. table.concat(specs, ' ') .. '?'

    if vim.fn.confirm(command, '&Yes\n&No', 2) == 1 then
        vim.pack.del(specs, { force = false })
    end
end, { nargs = '*', complete = 'packadd', desc = 'NvimPack remove inactive plugins' })

-- PackChanged callback
vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('core.PackChanged', { clear = true }),
    callback = function(ev)
        if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then return end

        local data = ev.data.spec.data
        if type(data) == 'table' and type(data.build) == 'function' then
            pcall(data.build, { path = ev.data.path })
        end
    end,
})

-- Packer
local group = vim.api.nvim_create_augroup('core.Packadd', { clear = true })

local lazyload = function(plug)
    local data = plug.spec.data

    if data.skip then return end

    local load = function(ev)
        if type(data.depends) == 'table' then
            for _, dep in ipairs(data.depends) do
                local src = type(dep) == 'string' and dep or dep.src
                local name = (src:gsub('%.git$', '')):match('[^/]+$')
                if name and name ~= '' then vim.cmd.packadd(name) end
            end
        end

        -- before packadd callback
        if type(data.before) == 'function' then
            pcall(data.before, ev)
        end

        vim.cmd.packadd(plug.spec.name)

        -- after packadd callback
        if type(data.config) == 'function' then
            pcall(data.config, ev)
        end
    end

    if not data.events then return load(plug) end

    vim.api.nvim_create_autocmd(data.events, {
        once = true, group = group, pattern = data.pattern, callback = load
    })
end

return function(options)
    local specs = {}

    for _, s in ipairs(options) do
        local data = vim.tbl_extend('force', s.data or {}, s)
        data.src, data.name, data.version, data.data = nil, nil, nil, nil

        for _, dep in ipairs(data.depends or {}) do
            if type(dep) == 'string' and not specs[dep] then
                specs[dep] = { src = dep, data = { skip = true } }
            end
            if type(dep) == 'table' and not specs[dep.src] then
                local depdata = vim.tbl_extend('force', dep.data or {}, dep)
                depdata.src, depdata.name, depdata.version, depdata.data, depdata.skip = nil, nil, nil, nil, true

                specs[dep.src] = { src = dep.src, name = dep.src, version = dep.version, data = depdata }
            end
        end

        if specs[s.src] then
            specs[s.src].data = data
        else
            specs[s.src] = { src = s.src, name = s.name, version = s.version, data = data }
        end
    end

    vim.pack.add(vim.tbl_values(specs), { confirm = false, load = lazyload })
end
