#!/usr/bin/lua

-- generate file name
local name = os.getenv("HOME") .. "/pictures/screenshots/" .. os.date("%Y-%m-%d.%H:%M:%S") .. ".png"

-- get screenshot range
local region = io.popen("slurp"):read("*l")

-- screenshot
if region and os.execute(string.format("grim -g '%s' '%s'", region, name)) then
    os.execute("wl-copy < " .. name)
    os.execute("dunstify 'screenshot' '" .. name .. "'")
end
