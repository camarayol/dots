#!/bin/bash

filename="$HOME/pictures/screenshots/$(date +'%Y-%m-%d.%H:%M:%S.%N').png"
if range=$(slurp) && [ $? -eq 0 ]; then
    grim -g "$range" "$filename"
    wl-copy < $filename && dunstify "screenshots" "$filename"
fi

