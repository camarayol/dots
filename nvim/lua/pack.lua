local Pack = {}

local state = {
    hook_by_name    = {},
    seen            = {},
    queue           = {},
    flush_scheduled = false,
    flushed         = false,
    initialized     = false,
}

local function notify_error(err)
    vim.schedule(function()
        vim.notify('(pack) ' .. err, vim.log.levels.ERROR)
    end)
end

local function basename(src)
    local name = src:gsub('/+$', ''):match('([^/]+)$') or src
    return name:gsub('%.git$', '')
end

local function normalize_spec(spec)
    if type(spec) == 'string' then
        spec = { source = spec }
    end

    local source = spec.source or spec.src
    if type(source) ~= 'string' or source == '' then
        error('(pack) plugin spec requires `source`')
    end

    return {
        source  = source,
        name    = spec.name or basename(source),
        version = spec.checkout or spec.version,
        depends = spec.depends or {},
        hook    = spec.hook,
        config  = spec.config,
    }
end

local function pack_event(spec, path)
    return {
        path   = path,
        source = spec.src,
        name   = spec.name,
        kind   = spec.kind,
    }
end

local function run_hook(hook, ev)
    if type(hook) ~= 'function' then
        return
    end

    local ok, err = pcall(hook, pack_event(ev.data.spec, ev.data.path))
    if not ok then
        notify_error(err)
    end
end

local function ensure_initialized()
    if state.initialized then
        return
    end
    state.initialized = true

    vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
            if ev.data.kind ~= 'install' and ev.data.kind ~= 'update' then
                return
            end

            local hook = state.hook_by_name[ev.data.spec.name]

            if hook ~= nil then
                local ok, err = pcall(vim.cmd.packadd, ev.data.spec.name)
                if not ok then
                    notify_error(err)
                end
            end

            ev.data.spec.kind = ev.data.kind
            run_hook(hook, ev)
        end,
    })

    vim.api.nvim_create_user_command('PackUpdate', function(input)
        local names = (#input.fargs > 0) and input.fargs or nil
        vim.pack.update(names, { force = input.bang })
    end, {
        bang  = true,
        nargs = '*',
        desc  = 'Update plugins',
    })

    vim.api.nvim_create_user_command('PackUpdateOffline', function(input)
        local names = (#input.fargs > 0) and input.fargs or nil
        vim.pack.update(names, { force = input.bang, offline = true })
    end, {
        bang = true,
        nargs = '*',
        desc = 'Update plugins without downloading from source',
    })

    vim.api.nvim_create_user_command('PackClean', function(input)
        local names = vim.iter(vim.pack.get())
            :filter(function(plugin)
                return not plugin.active
            end)
            :map(function(plugin)
                return plugin.spec.name
            end)
            :totable()

        if #names == 0 then
            vim.notify('(pack) Nothing to clean')
            return
        end

        if not input.bang then
            local answer = vim.fn.confirm(
                'Delete inactive plugins?\n' .. table.concat(names, '\n'),
                '&Yes\n&No',
                2
            )
            if answer ~= 1 then
                return
            end
        end

        vim.pack.del(names, { force = false })
    end, {
        bang = true,
        desc = 'Delete inactive plugins',
    })
end

local function flatten_specs(spec, entries, entries_by_name)
    spec = normalize_spec(spec)
    if spec.hook ~= nil then
        state.hook_by_name[spec.name] = spec.hook
    end

    local current = entries_by_name[spec.name]
    if current ~= nil then
        if type(spec.config) == 'function' then
            current.config = spec.config
        end
        if spec.hook ~= nil then
            current.hook = spec.hook
        end
        if spec.version ~= nil then
            current.version = spec.version
        end
        return
    end

    if state.seen[spec.name] then
        return
    end

    for _, dep in ipairs(spec.depends) do
        flatten_specs(dep, entries, entries_by_name)
    end

    state.seen[spec.name] = true
    table.insert(entries, spec)
    entries_by_name[spec.name] = spec
end

local function register_specs(specs)
    ensure_initialized()

    local list = (#specs == 0) and { specs } or specs
    local entries = {}
    local entries_by_name = {}

    for _, spec in ipairs(list) do
        flatten_specs(spec, entries, entries_by_name)
    end

    if #entries == 0 then
        return
    end

    local pack_specs = vim.tbl_map(function(spec)
        return {
            src = spec.source,
            name = spec.name,
            version = spec.version,
        }
    end, entries)

    vim.pack.add(pack_specs, { confirm = false, load = true })

    for _, spec in ipairs(entries) do
        if type(spec.config) == 'function' then
            local ok, err = pcall(spec.config)
            if not ok then
                notify_error(err)
            end
        end
    end
end

local function flush_queue()
    if state.flushed then
        return
    end
    state.flushed = true

    while #state.queue > 0 do
        local task = table.remove(state.queue, 1)
        local ok, err = pcall(task)
        if not ok then
            notify_error(err)
        end
    end
end

local function schedule_flush()
    if state.flushed or state.flush_scheduled then
        return
    end
    state.flush_scheduled = true

    vim.schedule(function()
        state.flush_scheduled = false
        flush_queue()
    end)
end

function Pack.now(specs)
    register_specs(specs)
end

function Pack.lazy(specs)
    table.insert(state.queue, function()
        register_specs(specs)
    end)
    schedule_flush()
end

function Pack.later(fn)
    table.insert(state.queue, fn)
    schedule_flush()
end

return Pack
