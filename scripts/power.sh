#!/bin/bash

declare -A power_menus=(
    # ["  lock"]="hyprlock"
    # ["  logout"]="hyprctl dispatch exit 1"
    ["  shutdown"]="systemctl poweroff"
    ["  reboot"]="systemctl reboot"
    ["  suspend"]="systemctl suspend"
)

default_rasi="inputbar { enabled: false; } listview { scrollbar: false; } window { width: 400px; }"
command=$(printf "%s\n" "${!power_menus[@]}" | rofi -dmenu -theme-str "$default_rasi window { height: 210px; } listview { lines: 3; }")

if [[ -n $command ]]; then
    confirm=$(printf "Yes\nNo" | rofi -dmenu -theme-str "$default_rasi window { height: 162px; } listview { lines: 2; }")

    if [[ -n $confirm && $confirm == "Yes" ]]; then
        ${power_menus[$command]}
    fi
fi

