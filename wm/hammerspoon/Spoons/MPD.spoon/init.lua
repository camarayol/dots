local mpd   = {
    name    = 'MPD',
    version = '0.0.1',
    author  = 'camarayol <camarayol@outlook.com>',
    license = 'MIT',
}
mpd.__index = mpd

mpd.address = '~/.mpd/socket'
mpd.playing = false

mpd.bar     = hs.menubar.new()
mpd.socket  = hs.socket.new()
mpd.logger  = hs.logger.new('MPD')

mpd.start = function()
    mpd.bar:setClickCallback(function()
        if not mpd.socket:connected() then
            mpd.connect()
            hs.timer.usleep(1000)
        end

        if mpd.socket:connected() then
            if mpd.playing then
                mpd.playing = false
                mpd.sendCommand('noidle')
                mpd.sendCommand('pause')
            else
                mpd.playing = true
                mpd.sendCommand('pause')
                mpd.sendCommand('idle player')
            end
        end
    end)

    mpd.socket:setCallback(function(info)
        -- connected
        if info:match('^OK MPD') then
            return
        end

        -- pause/play/noidle
        if info:match('^OK') then
            return
        end

        -- idle player
        if info:match('^changed') then
            mpd.sendCommand('currentsong')
            return
        end

        -- status
        if info:match('^volume') then
            local status = mpd.parseResponse(info)
            if status['state'] == 'play' then
                mpd.playing = true
            end
            return
        end

        -- currentsong
        if info:match('^file') then
            mpd.updateMenuBarTitle(mpd.parseResponse(info))
            if mpd.playing then mpd.sendCommand('idle player') end
            return
        end
    end)

    mpd.connect()
end

mpd.parseResponse = function(info)
    local kv = {}
    for line in info:gmatch('[^\n]+') do
        if line ~= 'OK' and not line:match('^ACK') then
            local k, v = line:match('^(.-):%s*(.*)$')
            if k and v then kv[k] = v end
        end
    end
    return kv
end

mpd.updateMenuBarTitle = function(info)
    mpd.bar:setTitle(info['Artist'] .. ' - ' .. info['Title'])
end

mpd.sendCommand = function(command)
    mpd.socket:send(command .. '\n'):read('OK\n')
end

mpd.connect = function()
    mpd.socket:connect(mpd.address, function()
        mpd.socket:read('\n')
        mpd.sendCommand('status')
        mpd.sendCommand('currentsong')
    end)
    hs.timer.doAfter(1, function()
        if not mpd.socket:connected() then
            mpd.logger.w('mpd socket connect failed!')
            mpd.connect()
        end
    end)
end

return mpd
