local wm      = {
    name    = 'WM',
    version = '0.0.1',
    author  = 'camarayol <camarayol@outlook.com>',
    license = 'MIT',
}
wm.__index    = wm

wm.fullScreen = function()

end

wm.focusLeft  = function()

end

wm.focusRight = function()

end

wm.setWidth   = function(w)
    local win = hs.window.focuseWindow()
    local f = win:frame()
    f.w = f.w + w
    win:setFrame(f)
end

return wm
