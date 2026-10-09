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
    vim.iter(vim.pack.get())
        :filter(function(x) return x.active and type(x.spec.data) == 'table' and type(x.spec.data.build) == 'function' end)
        :each(function(x) pcall(x.spec.data.build, { path = x.path }) end)
end, { desc = 'NvimPack run build callbacks for all plugins' })

-- Delete plugins
vim.api.nvim_create_user_command('PackClean', function(opts)
    local specs = vim.iter(vim.pack.get())
        :filter(function(x) return not x.active and (#opts.fargs == 0 or vim.tbl_contains(opts.fargs, x.spec.name)) end)
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
local Specs = {}

local group = vim.api.nvim_create_augroup('core.Packadd', { clear = true })

local function parse_spec_name(src)
    return src:gsub('%.git$', ''):match('[^/]+$')
end

local function add_normalized_specs(spec)
    spec = type(spec) == 'string' and { src = spec } or spec

    if type(spec) ~= 'table' then return end

    if spec.depends ~= nil then
        local depends = type(spec.depends) == 'string' and { spec.depends } or (spec.depends or {})

        vim.iter(depends):each(add_normalized_specs)

        spec.depends = vim.iter(depends):map(function(dep)
            return parse_spec_name(type(dep) == 'string' and dep or dep.src)
        end):totable()
    end

    local name = spec.name or parse_spec_name(spec.src)

    local normalize_spec = {
        src     = spec.src,
        name    = name,
        version = spec.version,
        data    = {
            depends = spec.depends,
            build   = spec.build,
            option  = spec.option,
            config  = spec.config,
            events  = spec.events,
            pattern = spec.pattern,
        }
    }

    if Specs[name] then
        Specs[name] = vim.tbl_extend('force', Specs[name], normalize_spec)
    else
        Specs[name] = normalize_spec
    end
end

local function packload(spec)
    if Specs[spec.name].data.loaded then return end

    if type(spec.data.depends) == 'table' then
        vim.iter(spec.data.depends):each(function(depname)
            packload(Specs[depname])
        end)
    end

    if type(spec.data.option) == 'function' then
        pcall(spec.data.option)
    end

    vim.cmd.packadd(spec.name)

    if type(spec.data.config) == 'function' then
        pcall(spec.data.config)
    end

    Specs[spec.name].data.loaded = true
end

--- @class core.packer.spec
--- @field src     string
--- @field name    string?
--- @field version string?
--- @field depends string|string[]|core.packer.spec|core.packer.spec[]?
--- @field build   function?
--- @field option  function?
--- @field config  function?
--- @field events  string|string[]?
--- @field pattern string|string[]?
--- @param specs   core.packer.spec[]
return function(specs)
    vim.iter(specs):each(add_normalized_specs)

    vim.pack.add(vim.tbl_values(Specs), {
        confirm = false,
        load = function(ev)
            local data = ev.spec.data

            if data.events then
                vim.api.nvim_create_autocmd(data.events, {
                    once = true, group = group, pattern = data.pattern, callback = function() packload(ev.spec) end
                })
            elseif data.config then
                packload(ev.spec)
            end
        end
    })
end
