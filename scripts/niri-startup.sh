#!/bin/bash

function check {
    command -v "$1" &>/dev/null && ! pidof "$1" &>/dev/null
}

# MPD: Music Play Daemon
check mpd && mpd

# mako: Wayland Notification Daemon
check mako && mako &

# Waybar: Wayland Bar
check waybar && waybar &

# wpaperd: Wayland Wallpaper Manager
check wpaperd && wpaperd -d

# udiskie: Automounter
check udiskie && udiskie &

# wl-clipboard: Wayland Command-Line Copy/Paste Utilities
# cliphist: Wayland Clipboard Manager
check wl-paste && {
    command -v cliphist &>/dev/null && wl-paste --watch cliphist -max-items 100 store &
}

# polkit-gnome: Gnome Authorization Manager
check /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 && {
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
}

# glance: Self-Hosted Dashboard
check glance && {
    glance --config ${XDG_CONFIG_HOME}/glance/glance.yml &
}

# Fcitx5: Input Tool
# If don't sleep fcitx5 cannot display the candidate box in xwayland applications. (why?)
# Remove /etc/xdg/autostart/org.fcitx.Fcitx5.desktop
#        /usr/share/dbus-1/services/org.fcitx.Fcitx5.service
# To disable fcitx5 autostart
check fcitx5 && {
    sleep 2 && fcitx5 --replace -d
}

