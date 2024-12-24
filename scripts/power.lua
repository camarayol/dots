#!/usr/bin/lua

local OrderedMap = {}
OrderedMap.__index = OrderedMap

function OrderedMap:new()
    local obj = { __keys = {}, __data = {} }
    setmetatable(obj, self)
    return obj
end

function OrderedMap:add(key, value)
    if not self.__data[key] then
        table.insert(self.__keys, key)
    end
    self.__data[key] = value
end

function OrderedMap:get(key) return self.__data[key] end

function OrderedMap:keys() return self.__keys end

function OrderedMap:count() return #self.__keys end

------------------------------

local menus = OrderedMap:new()
menus:add("  lock",     "hyprlock")
menus:add("  suspend",  "systemctl suspend")
menus:add("  logout",   "hyprctl dispatch exit 1")
menus:add("  reboot",   "systemctl reboot")
menus:add("  shutdown", "systemctl poweroff")

local function theme(lines)
    local def = [[
        window   { width: 400px; }
        inputbar { enabled: false; }
        listview { lines: %d; scrollbar: false; }
    ]]
    return string.format(def, lines)
end

local function confirm()
    local command = string.format([[echo -e "Yes\nNo" | rofi -dmenu -theme-str "%s"]], theme(2))
    return io.popen(command):read("*l") == "Yes"
end

local handle = io.popen(string.format([[echo -e "%s" | rofi -dmenu -theme-str "%s"]], table.concat(menus:keys(), "\n"), theme(menus:count())))
if handle then
    local command = handle:read("*l")
    if command and confirm() and menus:get(command) then
        os.execute(menus:get(command))
    end
    handle:close()
end
