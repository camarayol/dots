# !/usr/bin/env bash

DOTINK_CONF_FILE=dotink.conf

XDG_LOCAL_HOME=${XDG_LOCAL_HOME:-"$HOME/.local"}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

function usage {
    echo "Usage: $1 [OPTION]"
    echo "OPTION:"
    echo "    -i, install       create symlinks"
    echo "    -u, uninstall     remove symlinks"
}

function log {
    case "$1" in
        info)  shift; printf '\033[32m%s\033[0m\n' "$*" ;;
        warn)  shift; printf '\033[33m%s\033[0m\n' "$*" ;;
        error) shift; printf '\033[31m%s\033[0m\n' "$*" ;;
        *) echo $* ;;
    esac
}

function install {
    log info "====> Create symlinks start"

    while read -r source target; do
        [[ $source =~ ^\s*# || -z $source || -z $target ]] && continue

        source=$(realpath $(envsubst <<< "$source"))
        target=$(envsubst <<< "$target")

        [ ! -e "$source" ] && {
            log error "source file not exist: $source" && continue
        }

        [[ -L "$target" && ! -e "$target" ]] && {
            rm "$target" && log warn "remove invalid symlink: $target"
        }

        [ -e "$target" ] && {
            [ "$(realpath "$target")" != "$source" ] && {
                log error "target file exist: $target"
            }
            continue
        }

        mkdir -p "${target%/*}" || {
            log error "create directory failed: ${target%/*}" && continue
        }

        if ln -s "$source" "$target"; then
            log info "create symlink: $source -> $target"
        else
            log error "create symlink failed: $source -> $target"
        fi
    done < ${DOTINK_CONF_FILE}

    log info "<==== Create symlinks finished"
}

function uninstall {
    log info "====> Remove symlinks start"

    while read -r source target; do
        [[ $source =~ ^\s*# || -z $source || -z $target ]] && continue

        source=$(realpath $(envsubst <<< "$source"))
        target=$(envsubst <<< "$target")

        [ ! -e $target ] && continue

        if [ $source == $(realpath $target) ]; then
            rm $target && log info "remove symlink: $target"
        else
            log error "target not a symlink to source: $target"
        fi
    done < ${DOTINK_CONF_FILE}

    log info "<==== Remove symlinks finished"
}

case "$1" in
    install|-i)   install ;;
    uninstall|-u) uninstall ;;
    *) usage $0 ;;
esac

