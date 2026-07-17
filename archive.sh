#!/bin/bash


############################################################
#
# Frigate Archive
#
# Version : 2.0.0
# Author  : Jonathan Dalcin
# License : MIT
#
# Description:
# Main controller for the Frigate Archive system.
#
############################################################

BASE="/boot/config/custom/frigate-archive"


############################################
# Load modules
############################################

source "$BASE/config.conf"
source "$BASE/modules/utils.sh"
source "$BASE/modules/verify.sh"
source "$BASE/modules/transfer.sh"
source "$BASE/modules/database_cleanup.sh"


############################################
# Start
############################################

init_log

info "==============================================="
info " Frigate Archive V2.0 Starting"
info "==============================================="


############################################
# Configuration
############################################

info "Loading configuration..."

info "Recording Path : $SOURCE"
info "Archive Path   : $ARCHIVE"
info "Container      : $CONTAINER"

success "Configuration loaded."


############################################
# System checks
############################################

info "Running system checks..."


if [ ! -d "$SOURCE" ]; then
    error "Recording Folder Missing"
    exit 1
else
    success "Recording Folder OK"
fi


if [ ! -d "$ARCHIVE" ]; then
    error "Archive Folder Missing"
    exit 1
else
    success "Archive Folder OK"
fi


if [ ! -f "$FRIGATE_DB" ]; then
    error "Frigate Database Missing"
    exit 1
else
    success "Frigate Database OK"
fi


if command -v docker >/dev/null; then
    success "Docker available"
else
    error "Docker unavailable"
    exit 1
fi


if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER$"; then
    success "Frigate container exists"
else
    error "Frigate container missing"
    exit 1
fi


USAGE=$(df -P "$SOURCE" | awk 'NR==2 {print $5}' | tr -d '%')


info "Recording drive usage: ${USAGE}%"


success "All checks passed."



############################################
# Lock
############################################

if ! acquire_lock; then

    error "Unable to acquire lock. Exiting."

    exit 1

fi



############################################
# Archive decision
############################################

if [ "$USAGE" -lt "$START_THRESHOLD" ]; then

    info "Archive not required."

    release_lock

    exit 0

fi


info "Archive threshold reached."



############################################
# Find oldest recording day
############################################

DAY=$(find "$SOURCE" \
-mindepth 1 \
-maxdepth 1 \
-type d \
-printf "%f\n" | sort | head -1)



if [ -z "$DAY" ]; then

    info "No completed recording days available."

    release_lock

    exit 0

fi


info "Archive candidate:"
info "$DAY"



############################################
# Test mode
############################################

if [ "$TEST_MODE" = true ]; then

    success "TEST MODE ENABLED"

    info "No files will be moved."

fi



############################################
# Pre-transfer verification
############################################

ARCHIVE_DAY="$ARCHIVE/$DAY"


if [ -d "$ARCHIVE_DAY" ]; then

    info "Existing archive found."
    info "Running pre-transfer verification."

    verify_archive "$DAY"


    if [ $? -ne 0 ]; then

        error "Archive verification failed."

        release_lock

        exit 1

    fi

else

    info "No existing archive found."
    info "Skipping pre-transfer verification."

fi



############################################
# Transfer
############################################

archive_transfer "$DAY"


if [ $? -ne 0 ]; then

    error "Archive transfer stage failed."

    release_lock

    exit 1

else

    success "Archive transfer stage completed."

fi



############################################
# Database cleanup
############################################

cleanup_database "$DAY"


if [ $? -ne 0 ]; then

    error "Database cleanup failed."

else

    success "Database cleanup completed."

fi



############################################
# Unlock
############################################

release_lock


exit 0
