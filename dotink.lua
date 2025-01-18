#!/usr/bin/env lua

-- need install 'lua-filesystem' package first
-- run 'sudo pacman -S lua-filesystem' (archlinux)
-- or 'luarocks install luafilesystem' (luarocks)
local lfs = require('lfs')
local opts = require('opts')

local logger = {
    succs = function(s, ...) print('\x1b[32m[succs]', string.format(s, ...), '\x1b[0m') end,
    error = function(s, ...) print('\x1b[31m[error]', string.format(s, ...), '\x1b[0m') end,
}

-- get absolute path
local function absolute(path)
    -- TODO: $HOME $XDG_CONFIG_HOME ...
    if path:match('^%./') then
        local current = lfs.currentdir()
        path = path:gsub('^%.', tostring(current))
    elseif path:match('^~/') then
        local home = os.getenv('HOME')
        path = path:gsub('^~', tostring(home))
    end
    return path
end

-- get parent directory
local function parentdir(dir)
    return dir:gsub('/+$', ''):match('(.*/)')
end

local function create_symbolic_link(origin, target)
    if opts.create_directory then
        local dir = parentdir(target)
        if not os.execute('mkdir -p ' .. dir) then
            logger.error('create %s failed.', dir)
            return
        end
    end

    local ret, err = lfs.link(origin, target, true)
    if ret then
        logger.succs("link %s -> %s.", origin, target)
    else
        logger.error("link %s -> %s. %s", origin, target, err)
    end
end

local function link_targets(origin, target)
    if not lfs.symlinkattributes(origin) then
        logger.error("origin file %s doesn't exist.", origin)
        return false
    end

    local attrtaget = lfs.symlinkattributes(target)
    -- target doesn't exist
    if not attrtaget then return true end

    -- target exist and is not a symbolic link
    if attrtaget.mode ~= 'link' then
        logger.error("exist %s mode '%s'", target, attrtaget.mode)
        return false
    end

    -- original file has already been symlinked to the target
    if attrtaget.target == origin then
        logger.succs("exist %s -> %s", target, origin)
        return false
    end

    local currentdir = lfs.currentdir()
    lfs.chdir(parentdir(target))
    if opts.remove_invalid_links and lfs.symlinkattributes(absolute(attrtaget.target)) == nil then
        -- automatic remove exist invalid symbolic link
        local ret, err = os.remove(target)
        if not ret then
            logger.error("remove invalid link %s -> %s. %s", target, attrtaget.target, err)
            lfs.chdir(currentdir)
            return false
        else
            logger.succs("remove invalid link %s -> %s.", target, attrtaget.target)
            lfs.chdir(currentdir)
            return true
        end
    end

    lfs.chdir(currentdir)
    logger.error("exist %s -> %s.", target, attrtaget.target)
    return false
end

local function unlink_targets(origin, target)
    local attrtaget = lfs.symlinkattributes(target)
    if not attrtaget then
        logger.succs("%s doesn't exist.", target)
        return
    end

    if attrtaget.mode ~= 'link' then
        logger.error("exist %s mode '%s'.", target, attrtaget.mode)
        return
    end

    if attrtaget.target == origin then
        local ret, error = os.remove(target)
        if not ret then
            logger.error("remove link %s. %s", target, error)
        else
            logger.succs("remove link %s.", target)
        end
    else
        logger.error("link exist %s -> %s.", target, attrtaget.target)
    end
end

local function usage()
    print("Usage: lua " .. arg[0] .. " [OPTION]")
    print("OPTION:")
    print("    i, -i, link         create links")
    print("    u, -u, unlink       remove links")
    os.exit(1)
end

-- main
local cmd = arg[1] or usage()
if cmd:match('^%-?i$') or cmd:match('^link$') then
    print("====> link start")
    for origin, target in pairs(opts.links) do
        origin, target = absolute(origin), absolute(target)
        if link_targets(origin, target) then
            create_symbolic_link(origin, target)
        end
    end
    print("<==== link finished")
elseif cmd:match('^%-?u$') or cmd:match('^unlink$') then
    print("====> unlink start")
    for origin, target in pairs(opts.links) do
        unlink_targets(absolute(origin), absolute(target))
    end
    print("<==== unlink finished")
else
    return usage()
end
