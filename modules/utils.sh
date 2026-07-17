#!/bin/bash

############################################
# Frigate Archive V2
# Utility Functions
############################################


############################################
# Logging
############################################

init_log()
{
    if [ -z "$LOGFILE" ]; then
        LOGFILE="/tmp/frigate_archive_v2.log"
    fi

    touch "$LOGFILE"
}


log()
{
    local LEVEL="$1"
    shift

    local MESSAGE="$*"

    local LINE
    LINE="$(date '+%Y-%m-%d %H:%M:%S') [$LEVEL] $MESSAGE"

    echo "$LINE"

    if [ -n "$LOGFILE" ]; then
        echo "$LINE" >> "$LOGFILE"
    fi
}


info()
{
    log "INFO" "$*"
}


success()
{
    log "SUCCESS" "$*"
}


warning()
{
    log "WARNING" "$*"
}


warn()
{
    warning "$*"
}


error()
{
    log "ERROR" "$*"
}



############################################
# Lock Handling
############################################

acquire_lock()
{

    if [ -f "$LOCKFILE" ]; then


        OLD_PID=$(grep PID "$LOCKFILE" | cut -d= -f2)


        if kill -0 "$OLD_PID" 2>/dev/null; then

            error "Another archive process is already running. PID: $OLD_PID"

            return 1

        else

            warn "Stale lock found. Removing."

            rm -f "$LOCKFILE"

        fi

    fi


    cat > "$LOCKFILE" <<EOF
PID=$$
START=$(date '+%F %T')
HOST=$(hostname)
EOF


    success "Lock acquired."

    return 0
}



release_lock()
{

    if [ -f "$LOCKFILE" ]; then

        rm -f "$LOCKFILE"

        success "Lock released."

    fi

}
