#!/bin/bash

init_log() {

    mkdir -p "$(dirname "$LOGFILE")"

    touch "$LOGFILE"

}


log() {

    LEVEL="$1"

    shift

    printf "%s %-8s %s\n" \
    "$(date '+%F %T')" \
    "[$LEVEL]" \
    "$*" \
    | tee -a "$LOGFILE"

}


info() {

    log INFO "$@"

}


warn() {

    log WARNING "$@"

}


error() {

    log ERROR "$@"

}


success() {

    log SUCCESS "$@"

}
