function fish_greeting
    # echo welcome to fish
end

function fish_prompt
    echo -n (set_color -i blue) (prompt_pwd)
    if command -sq git
        set branch (command git describe --contains --all HEAD 2>/dev/null)
        if not command git diff --quiet --exit-code 2>/dev/null
            echo -n (set_color red) $branch"*"
        else
            echo -n (set_color green) $branch
        end
    end
    echo -n (set_color magenta)" ❯ "(set_color normal)
end

function fish_right_prompt
    if command -sq git
        set commit (command git rev-parse HEAD 2>/dev/null | string sub -l 7)
    end
    echo -n (set_color brblack) $commit (date "+%H:%M")(set_color normal)
end

# keybinds
function fish_user_key_bindings
    bind \el forward-char   # <M-l>
end

function add_environment --description "export environment once"
    set -l env  $argv[1]
    set -l path $argv[2]
    if not contains -- $path $$env
        set -gx $env $path $$env
    end
end

set -gx EDITOR          "nvim"
set -gx XDG_LOCAL_HOME  "$HOME/.local"
set -gx XDG_CACHE_HOME  "$HOME/.cache"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx CARGO_HOME      "$XDG_LOCAL_HOME/rust/cargo"
set -gx RUSTUP_HOME     "$XDG_LOCAL_HOME/rust/rustup"

add_environment PATH            "$XDG_LOCAL_HOME/bin"
add_environment PATH            "$XDG_LOCAL_HOME/bin/scripts"
add_environment PATH            "$XDG_LOCAL_HOME/rust/cargo/bin"
add_environment CPATH           "$XDG_LOCAL_HOME/include"
add_environment LIBRARY_PATH    "$XDG_LOCAL_HOME/lib"
add_environment LD_LIBRARY_PATH "$XDG_LOCAL_HOME/lib"

## archlinux pacman
function pacmans --description "pacman -S"
    set -l pkg (begin; pacman -Slq; pacman -Qq; end | sort | uniq -u | fzf -q "$1" -m --preview "pacman -Si {1}")
    if test -n "$pkg"
        commandline -r "sudo pacman -S $pkg"
    end
end

function pacmanr --description "pacman -Rns"
    set -l pkg (pacman -Qq | fzf -q "$1" -m --preview "pacman -Qi {1}")
    if test -n "$pkg"
        commandline -r "sudo pacman -Rns $pkg"
    end
end

function pacmanc --description "pacman -Rns \$(pacman -Qdtq)"
    set -l pkg (pacman -Qdtq)
    if test -n "$pkg"
        sudo pacman -Rns $pkg
    end
end

function backlight --description "set backlight"
    echo $argv[1] | sudo tee /sys/class/backlight/amdgpu_bl1/brightness
end

if status is-interactive
    set -U fish_complete_inline 1

    # alias
    alias x   extract # functions/extract.fish
    alias nv  nvim
    alias lg  lazygit
    alias zj  zellij

    alias ns  niri-session
    alias vvi "nvim $XDG_CONFIG_HOME/nvim/init.lua"
    alias vrc "nvim $XDG_CONFIG_HOME/fish/config.fish"
    alias src "source $XDG_CONFIG_HOME/fish/config.fish"

    # source command keybindings
    if command -q zoxide
        zoxide init fish | source
    end

    if command -q fzf
        fzf --fish | source
        set -gx FZF_COMPLETION_TRIGGER "~~"
        set -gx FZF_DEFAULT_OPTS "--reverse --bind 'alt-j:down' --bind 'alt-k:up' --bind 'tab:accept' --bind 'ctrl-j:preview-down' --bind 'ctrl-k:preview-up'"
    end

    if test (tty) = "/dev/tty1" && test -z "$DISPLAY_SESSION_TYPE"
        niri-session
    end
end

