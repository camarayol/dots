#!/usr/bin/lua

local index = 0
local active_index = 0
local active = io.popen("hyprctl hyprpaper listactive"):read("*l")
local wallpapers = {}
local handle = io.popen("hyprctl hyprpaper listloaded")

repeat
    local wallpaper = handle and handle:read("*l") or nil
    if wallpaper then
        index = index + 1
        if string.find(active, wallpaper) then active_index = index end
        table.insert(wallpapers, wallpaper)
    end
until wallpaper == nil

os.execute(string.format([[hyprctl hyprpaper wallpaper ",%s"]],
    (active_index + 1 > #wallpapers) and wallpapers[0] or wallpapers[active_index + 1]
))
