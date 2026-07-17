#!/bin/bash

############################################
# System Validation Checks
############################################


check_directory() {

    local DIR="$1"
    local NAME="$2"


    if [ ! -d "$DIR" ]; then

        error "$NAME does not exist: $DIR"
        return 1

    fi


    TESTFILE="$DIR/.frigate_archive_test"


    if ! touch "$TESTFILE" 2>/dev/null; then

        error "$NAME is not writable: $DIR"
        return 1

    fi


    rm -f "$TESTFILE"


    success "$NAME OK"

}



check_file() {

    local FILE="$1"
    local NAME="$2"


    if [ ! -f "$FILE" ]; then

        error "$NAME missing: $FILE"
        return 1

    fi


    success "$NAME OK"

}



check_docker() {


    if ! command -v docker >/dev/null 2>&1; then

        error "Docker command not found"
        return 1

    fi


    success "Docker available"

}



check_container() {

    local NAME="$1"


    if ! docker inspect "$NAME" >/dev/null 2>&1; then

        error "Container not found: $NAME"
        return 1

    fi


    success "Frigate container exists"

}



disk_usage() {

    df -P "$1" | awk 'NR==2 {gsub("%",""); print $5}'

}
