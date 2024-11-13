#!/usr/bin/lua
-- 

local connections = io.popen([[nmcli -g NAME connection]]):read("*a")
local status = string.find(io.popen([[nmcli -fields WIFI g | sed 1d]]):read("*l"), "enabled") and true or false
local wifi = io.popen([[nmcli --fields "SSID" device wifi list | sed 1d | sed "s/ *//g" | sort -u]]):read("*a")

local command = io.popen(string.format([[echo -e "%s\n%s" | rofi -dmenu -i -selected-row %d]],
    status and "  Disable" or "  Enable", wifi, status and 1 or 0)):read("*l")

if not command then
    return
elseif command == "  Disable" then
    os.execute([[nmcli radio wifi off]])
elseif command == "  Enable" then
    os.execute([[nmcli radio wifi on]])
else
    if string.find(connections, command) then
        local c = string.format([[sudo nmcli connection up id %s]], command)
        if string.find(io.popen(c):read("*l"), "successfully") then
            os.execute(string.format([[dunstify "Connected to '%s' success!"]], command))
        end
    else
        local password = io.popen([[rofi -dmenu]]):read("*l")
        local c = string.format([[sudo nmcli device wifi connect %s password %s]], command, password)
        if string.find(io.popen(c):read("*l"), "successfully") then
            os.execute(string.format([[dunstify "Connected to '%s' success!"]], command))
        end
    end
end
