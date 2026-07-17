#!/bin/bash

############################################
# Unraid Notifications
############################################


notify() {


    if [ "$ENABLE_NOTIFICATIONS" != "true" ]; then

        return 0

    fi


    /usr/local/emhttp/webGui/scripts/notify \
    -e "$NOTIFICATION_TITLE" \
    -s "$1" \
    -d "$2"

}



notify_start() {


    notify \
    "Archive Started" \
    "$1"


}



notify_success() {


    notify \
    "Archive Completed" \
    "$1"


}



notify_error() {


    notify \
    "Archive Failed" \
    "$1"


}
