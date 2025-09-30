local playing = false
local bar = hs.menubar.new()
local socket = hs.socket.new()

local function parseResponse(data)
    local info = {}
    for line in data:gmatch('[^\n]+') do
        if line ~= 'OK' and not line:match('^ACK') then
            local key, value = line:match('^(.-):%s*(.*)$')
            if key and value then info[key] = value end
        end
    end
    return info
end

local function updateTitle(info) bar:setTitle(info['Artist'] .. ' - ' .. info['Title']) end

local function sendCommand(command) socket:send(command .. '\n'):read('OK\n') end

socket:setCallback(function(data)
    if data:match('^OK MPD') then
        -- connected
    elseif data:match('^OK') then
        -- pause/play
        playing = not playing
        if playing then sendCommand('idle player') end
    elseif data:match('^changed') then
        -- idle player changed
        sendCommand('currentsong')
    elseif data:match('^file') then
        -- currentsong
        updateTitle(parseResponse(data))
        if playing then sendCommand('idle player') end
    end
end)

local function connectMpd()
    socket:connect('~/.mpd/socket', function()
        socket:read('\n')
        sendCommand('currentsong')
    end)
    hs.timer.doAfter(1, function()
        if not socket:connected() then connectMpd() end
    end)
end

bar:setClickCallback(function()
    if not socket:connected() then return connectMpd() end
    if playing then sendCommand('noidle') end
    sendCommand('pause')
end)

connectMpd()
