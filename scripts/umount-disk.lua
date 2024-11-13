#!/usr/bin/lua
local rofi = [[
    configuration { show-icons: false; }
    window { height: 400px; }
    inputbar { children: [ 'textbox-prompt-colon' ]; }
    textbox-prompt-colon { str: 'udiskie-umount:'; }
    listview { scrollbar: false; }
]]

local function confirm()
    local command = string.format([[echo -e "Yes\nNo" | rofi -dmenu -theme-str "%s"]], rofi .. "listview { lines: 2; }")
    return io.popen(command):read("*l") == "Yes"
end

local dirs = ""
local mount_directory = "/run/media/$USER/"
local handle = io.popen("ls " .. mount_directory)

repeat
    local dir = handle and handle:read("*l") or nil
    if dir then
        if string.len(dirs) > 0 then dirs = dirs .. "\\n" end
        dirs = dirs .. mount_directory .. dir
    end
until dir == nil

if string.len(dirs) > 0 then
    local command = string.format([[echo -e "%s" | rofi -dmenu -theme-str "%s"]], dirs, rofi)
    local select = io.popen(command):read("*l")
    if select and confirm() then
        os.execute(string.format([[udiskie-umount -d "%s"]], select))
    end
end
