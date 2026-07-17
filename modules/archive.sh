#!/bin/bash

############################################
# Frigate Archive Engine
############################################


archive_required() {

    CURRENT=$(disk_usage "$SOURCE")

    if [ "$CURRENT" -ge "$START_THRESHOLD" ]; then
        return 0
    fi

    return 1

}



find_oldest_day() {

    TODAY=$(date +%F)

    find "$SOURCE" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        ! -name "$TODAY" \
        | sort \
        | head -1

}



show_archive_plan() {


    OLD=$(find_oldest_day)


    if [ -z "$OLD" ]; then

        info "No completed recording days available."

        return 1

    fi


    DAY=$(basename "$OLD")


    info "Archive candidate:"
    info "$DAY"

    
    if [ "$TEST_MODE" = "true" ]; then

        success "TEST MODE ENABLED"
        info "No files will be moved."

    fi


}
