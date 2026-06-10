local wz = require('wezterm')

wz.on('gui-startup', function(cmd)
    local _, _, window = wz.mux.spawn_window(cmd or {})
    local window = window:gui_window()
    local screen = wz.gui.screens().active
    local dimensions = window:get_dimensions()

    window:set_position(screen.x + (screen.width - dimensions.pixel_width) / 2,
        screen.y + (screen.height - dimensions.pixel_height) / 2)
end)

local c = {}

c.default_prog = { 'powershell.exe' }

c.color_scheme = 'OneHalfDark'

c.colors = {
    brights = {
        '#7f8490',
        '#e06c75',
        '#98c379',
        '#e5c07b',
        '#61afef',
        '#c678dd',
        '#56b6c2',
        '#dcdfe4',
    },
}

c.font_size = 16
c.font = wz.font_with_fallback {
    'FreeMono',
    'LXGWWenKaiMono Nerd Font Light',
    -- 'LXGW WenKai Mono GB Screen'
}

c.initial_cols = 160
c.initial_rows = 50

c.window_decorations = 'RESIZE'

c.enable_tab_bar = false

c.automatically_reload_config = true

c.window_padding = {
    bottom = '14px',
}

c.mouse_bindings = {
    { mods = 'CTRL', event = { Drag = { streak = 1, button = 'Left' } }, action = wz.action.StartWindowDrag },
    { mods = 'CTRL', event = { Drag = { streak = 1, button = 'Left' } }, action = wz.action.StartWindowDrag, mouse_reporting = true },
    { mods = 'CTRL', event = { Down = { streak = 1, button = 'Left' } }, action = wz.action.Nop,             mouse_reporting = true },
}

c.keys = {
    { mods = 'ALT|SHIFT', key = 'R', action = wz.action.ReloadConfiguration },
    { mods = 'ALT',       key = 't', action = wz.action.SpawnTab 'CurrentPaneDomain' },
    { mods = 'ALT',       key = '[', action = wz.action.ActivateTabRelative(-1) },
    { mods = 'ALT',       key = ']', action = wz.action.ActivateTabRelative(1) },
    { mods = 'ALT|SHIFT', key = 'q', action = wz.action.CloseCurrentTab { confirm = true } },
}


return c
