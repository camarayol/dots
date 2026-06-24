--- @diagnostic disable: unused-local, undefined-global
local am   = {
    name    = 'AM',
    version = '0.0.1',
    author  = 'camarayol <camarayol@outlook.com>',
    license = 'MIT',
}

am.__index = am

am.bar     = hs.menubar.new()
am.logger  = hs.logger.new('AM')

function am.start()
    local result = am.getPlayState()

    local title = 'Apple Music'
    if result[1] == 'paused' or result[1] == 'playing' then
        title = string.format('%s - %s', result[2], result[3])
    end

    am.bar:setTitle(title)
    am.bar:setClickCallback(am.onTitleClicked)
    am.registNotification()
end

function am.getPlayState()
    local ok, result = hs.osascript.applescript([[
        tell application "Music"
            if not (it is running) then
                return { "norunning", "", "" }
            end if

            try
                return { player state as text, artist of current track, name of current track }
            on error
                return { player state as text, "", "" }
            end try
        end tell
    ]])

    if not ok then
        am.logger.w('getPlayState failed. result: ', tostring(result))
        return { 'norunning', '', '' }
    end

    return result
end

function am.onTitleClicked()
    local result = am.getPlayState()
    if result[1] ~= 'norunning' then
        return am.togglePlayPause()
    end

    hs.osascript.applescript [[tell application "Music" to run]]

    hs.timer.doAfter(1, am.togglePlayPause)
end

function am.togglePlayPause()
    hs.eventtap.event.newSystemKeyEvent("PLAY", true):post()
    hs.eventtap.event.newSystemKeyEvent("PLAY", false):post()
end

function am.registNotification()
    hs.distributednotifications.new(am.parseNotification, 'com.apple.Music.playerInfo'):start()
end

function am.parseNotification(name, object, userInfo)
    if userInfo['Artist'] and userInfo['Name'] then
        am.bar:setTitle(userInfo['Artist'] .. ' - ' .. userInfo['Name'])
    end
end

return am
