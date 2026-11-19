#!/usr/bin/env bash

DOTINK_CONF_FILE=dotink.conf

export XDG_LOCAL_HOME=${XDG_LOCAL_HOME:-"$HOME/.local"}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

function normal_realpath {
    local path=$1
    [ -z "$path" ] && return 1
    case $path in /*) ;; *) path=./$path ;; esac
    ( if cd -P -- "$path" 2>/dev/null; then
          printf '%s\n' "$PWD"
      elif cd -P -- "${path%/*}" 2>/dev/null; then
          printf '%s/%s\n' "${PWD%/}" "${path##*/}"
      else
          printf '%s\n' "$path"
      fi )
}

function expand_vars {
    local s=$1 head name tail n=0
    while (( ++n < 64 )) && [[ $s =~ ^(.*)\$\{([A-Za-z_][A-Za-z0-9_]*)\}(.*)$ ]]; do
        head=${BASH_REMATCH[1]} name=${BASH_REMATCH[2]} tail=${BASH_REMATCH[3]}
        s=$head${!name-}$tail
    done
    while (( ++n < 64 )) && [[ $s =~ ^(.*)\$([A-Za-z_][A-Za-z0-9_]*)(.*)$ ]]; do
        head=${BASH_REMATCH[1]} name=${BASH_REMATCH[2]} tail=${BASH_REMATCH[3]}
        s=$head${!name-}$tail
    done
    printf '%s' "$s"
}

function is_link_to {
    [ -L "$1" ] && [ -e "$1" ] && [ "$1" -ef "$2" ]
}

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
        *) echo "$*" ;;
    esac
}

function install {
    log info "====> Create symlinks start"

    while read -r source target; do
        [[ $source =~ ^\s*# || -z $source || -z $target ]] && continue

        source=$(normal_realpath "$(expand_vars "$source")")
        target=$(expand_vars "$target")

        [ ! -e "$source" ] && {
            log error "source file not exist: $source" && continue
        }

        [[ -L "$target" && ! -e "$target" ]] && {
            rm "$target" && log warn "remove invalid symlink: $target"
        }

        [ -e "$target" ] && {
            if is_link_to "$target" "$source"; then
                log warn "symlink already exists: $target"
            else
                log error "target file exist: $target"
            fi
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
    done < "${DOTINK_CONF_FILE}"

    log info "<==== Create symlinks finished"
}

function uninstall {
    log info "====> Remove symlinks start"

    while read -r source target; do
        [[ $source =~ ^\s*# || -z $source || -z $target ]] && continue

        source=$(normal_realpath "$(expand_vars "$source")")
        target=$(expand_vars "$target")

        [ ! -e "$target" ] && continue

        if is_link_to "$target" "$source"; then
            rm "$target" && log info "remove symlink: $target"
        else
            log error "target not a symlink to source: $target"
        fi
    done < "${DOTINK_CONF_FILE}"

    log info "<==== Remove symlinks finished"
}

case "$1" in
    install|-i)   install ;;
    uninstall|-u) uninstall ;;
    *) usage "$0" ;;
esac
