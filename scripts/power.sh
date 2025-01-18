#!/bin/bash

# archlinux with hyprland (systemd)
# declare -A power_menus=(
#     ["  lock"]="hyprlock"
#     ["  suspend"]="systemctl suspend"
#     ["  logout"]="hyprctl dispatch exit 1"
#     ["  reboot"]="systemctl reboot"
#     ["  shutdown"]="systemctl poweroff"
# )

# voidlinux with niri (runit)
declare -A power_menus=(
    ["  logout"]="niri msg action quit"
    ["  suspend"]="loginctl suspend"
    ["  shutdown"]="loginctl poweroff"
    ["  reboot"]="loginctl reboot"
)

default_rasi="inputbar { enabled: false; } listview { scrollbar: false; } window { width: 400px; }"
command=$(printf "%s\n" "${!power_menus[@]}" | rofi -dmenu -theme-str "$default_rasi window { height: 300px; } listview { lines: 5; }")

if [[ -n $command ]]; then
    confirm=$(printf "Yes\nNo" | rofi -dmenu -theme-str "$default_rasi window { height: 160px; } listview { lines: 2; }")

    if [[ -n $confirm && $confirm == "Yes" ]]; then
        ${power_menus[$command]}
    fi
fi

