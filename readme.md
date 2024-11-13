# My dots

- OS: Archlinux
- WM: Hyprland
- CPU: INTEL
- GPU: AMD

## install packages

- base packages

    ```sh
    sudo pacman -S fish alacritty hyprland waybar dunst udiskie wl-clipboard rofi-wayland \
        networkmanager grim slurp openssh intel-ucode bluez blueman net-tools
    ```

- audio packages

    ```sh
    sudo pacman -S pipewire pipewire-alsa pipewire-jack pipewire-audio pipewire-pulse \
        pipewire-media-session pavucontrol
    ```

- fcitx5 packages

    ```sh
    sudo pacman -S fcitx5 fcitx5-rime fcitx5-lua fcitx5-configtool librime
    ```

- other packages

    ```sh
    sudo pacman -S fzf flatpak fastfetch unzip neovim git lazygit zoxide wget man-db mpd mpc ncmpcpp \
        ripgrep translate-shell
    ```

- AMD GPU and steam packages

    ```sh
    sudo pacman -S steam vulkan-radeon lib32-vulkan-radeon lib32-vulkan-intel lib32-libdrm lib32-fontconfig \
        lib32-gdk-pixbuf2 lib32-libice lib32-libnm lib32-pipewire lib32-libpulse lib32-libxrandr lib32-glu  \
        lib32-libsm lib32-sdl2 lib32-libva lib32-libvdpau lib32-libxinerama lib32-openal lib32-gtk2
    ```

## setup fcitx5

```sh
sudo vim /etc/environment

QT_IM_MODULE=fcitx
GTK_IM_MODULE=fcitx
SDL_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
GLFW_IM_MODULE=ibus
```

