return {
    links = {
        ['./nvim']             = '~/.config/nvim',
        ['./fish']             = '~/.config/fish',
        ['./scripts']          = '~/.local/bin/scripts',

        ['./fcitx5']           = '~/.config/fcitx5',
        ['./fcitx5/rime']      = '~/.local/share/fcitx5/rime',
        ['./fcitx5/themes']    = '~/.local/share/fcitx5/themes',

        ['./terminal/foot']    = '~/.config/foot',
        ['./terminal/ghostty'] = '~/.config/ghostty',

        ['./wm/hypr']          = '~/.config/hypr',
        ['./wm/niri']          = '~/.config/niri',
        ['./wm/rofi']          = '~/.config/rofi',
        ['./wm/mako']          = '~/.config/mako',
        ['./wm/waybar']        = '~/.config/waybar',
        ['./wm/wpaperd']       = '~/.config/wpaperd',

        ['./tools/mpd']        = '~/.config/mpd',
        ['./tools/ncmpcpp']    = '~/.config/ncmpcpp',
        ['./tools/zellij']     = '~/.config/zellij',
        ['./tools/mangohud']   = '~/.config/mangohud',
        ['./tools/glance']     = '~/.config/glance',
    },

    -- automaticlly create non-existent directory
    create_directory = true, ---@type true | false

    -- automaticlly remove exist but invalid 'link' files
    remove_invalid_links = true, ---@type true | false
}
