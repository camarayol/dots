#!/bin/bash

DOTINK_CONF_FILE=dotink.conf

function usage {
    echo "Usage: $1 [OPTION]"
    echo "OPTION:"
    echo "    -i, install       create symlinks"
    echo "    -u, uninstall     remove symlinks"
}

function log {
    case "$1" in
        info)  shift && echo -e "\e[32m$*\e[0m" ;;
        warn)  shift && echo -e "\e[33m$*\e[0m" ;;
        error) shift && echo -e "\e[31m$*\e[0m" ;;
        *) echo $* ;;
    esac
}

function install {
    log info "====> Create symlinks start"

    while read -r source target; do
        [[ $source =~ ^\s*# || -z $source || -z $target ]] && continue

        source=$(realpath --no-symlinks $(eval echo $source))
        target=$(realpath --no-symlinks $(eval echo $target))

        [ ! -e $source ] && {
            log error "source file not exist: $source"
            continue
        }

        [[ -L $target && ! -e $target ]] && {
            rm $target
            log warn "remove invalid symlink: $target -> $(realpath $target)"
        }

        [ -e $target ] && {
            if [ $(realpath $target) != $source ]; then
                log error "target file exist: $target"
            fi
            continue
        }

        mkdir -p ${target%/*} || {
            log error "create directory failed: ${target%/*}"
            continue
        }

        if ln -s $source $target; then
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

        source=$(realpath --no-symlinks $(eval echo $source))
        target=$(realpath --no-symlinks $(eval echo $target))

        [ ! -e $target ] && continue

        if [ $source == $(realpath $target) ]; then
            rm $target
            log info "remove symlink file: $target"
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

