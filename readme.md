<h1 align="center"><a>dots</a></h1>

```markdown
- cpu:       intel
- gpu:       amd
- os:        archlinux
- wm:        niri
- shell:     fish
- terminal:  ghostty
- launcher:  rofi-wayland
- editor:    neovim
- topbar:    waybar
- notify:    mako
- wallpaper: wpaperd
```

## automatic login

```sh
sudo systemctl edit getty@tty1.service

    [Service]
    ExecStart=
    ExecStart=-/usr/bin/agetty -o '-p -f -- \\u' --noclear --autologin ${username} %I $TERM


sudo vim ~/.config/fish/config.fish

    if test (tty) = "/dev/tty1" && test -z "$DISPLAY_SESSION_TYPE"
        niri-session
    end
```

## archlinux packages backup

```sh
pacman -Qqen > packages.txt

sudo pacman -S --needed - < packages.txt
```

## music player

```sh
sudo pacman -S mpd mpc ncmpcpp
```

## automatic mount device

```sh
sudo pacman -S udiskie
```

## clipboard history

```sh
sudo pacman -S wl-clipboard cliphist

wl-paste --watch cliphist -max-items 100 store &
cliphist list | rofi -dmenu -now-show-icons | cliphist decode | wl-copy
```

## screenshot

```sh
sudo pacman -S grim slurp

filename="$HOME/pictures/screenshots/$(date +'%Y-%m-%d.%H:%M:%S.%N').png"
if range=$(slurp) && [ $? -eq 0 ]; then
    grim -g "$range" "$filename"
    wl-copy < $filename && notify-send "screenshots" "$filename"
fi
```

## telnet

```sh
sudo pacman -S net-tools
```

## fcitx5

```sh
sudo pacman -S fcitx5 fcitx5-rime fcitx5-lua fcitx5-qt fcitx5-configtool kwindowsystem librime

sudo vim /etc/environment
QT_IM_MODULE=fcitx
GTK_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
GLFW_IM_MODULE=ibus
```

## steam dependency library

```sh
sudo pacman -S steam vulkan-radeon lib32-vulkan-radeon lib32-vulkan-intel lib32-libdrm lib32-fontconfig \
    lib32-gdk-pixbuf2 lib32-libice lib32-libnm lib32-pipewire lib32-libpulse lib32-libxrandr lib32-glu \
    lib32-libsm lib32-sdl2 lib32-libva lib32-libvdpau lib32-libxinerama lib32-openal lib32-gtk2
```

## lact gpu configuration tool

```sh
# yay -S lact-bin
sudo pacman -S lact

# https://wiki.archlinux.org/title/AMDGPU#Boot_parameter
printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))" # amdgpu.ppfeaturemask=0xfff7ffff

sudo vim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="... amdgpu.ppfeaturemask=0xfff7ffff"

grub2-mkconfig -o /boot/grub2/grub.cfg
```

## xwayland

```sh
sudo pacman -S xwayland-satellite

DISPLAY=":0"
systemctl --user enable --now xwayland-satellite.service
```

## record terminal

- install `asciinema` and `agg`

    ```sh
    git clone https://github.com/asciinema/asciinema.git && cd asciinema
    cargo build --release

    git clone https://github.com/asciinema/agg.git && cd agg
    cargo build --release
    ```

- usage

    ```sh
    asciinema rec demo.cast
    agg demo.cast demo.git
    ```
