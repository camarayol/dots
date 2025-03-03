#!/bin/bash

# music player daemon
pidof mpd || mpd

# mako
mako &

# top bar
waybar &

# wallpaper
wpaperd -d

# automatic mount usb devices
udiskie &

# wayland clipbort
wl-paste --watch cliphist -max-items 100 store &

# if don't sleep fcitx5 cannot display the candidate box in xwayland applications. (why?)
# remove /etc/xdg/autostart/org.fcitx.Fcitx5.desktop and /usr/share/dbus-1/services/org.fcitx.Fcitx5.service

sleep 2 && fcitx5 --replace -d

