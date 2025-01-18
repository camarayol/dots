#!/bin/bash

# pipewire
pidof pipewire || dbus-run-session pipewire &

# xwayland
xwayland-satellite &

# music player daemon
pidof mpd || mpd &

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
sleep 2 && fcitx5 --replace -d

