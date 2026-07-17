#!/bin/bash

############################################################
#
# Frigate Archive
#
# Author  : Jonathan Dalcin
# License : MIT
#
# Description:
# Main controller for the Frigate Archive system.
#
############################################################

BASE="/boot/config/custom/frigate-archive"
VERSION_FILE="$BASE/VERSION"


############################################################
# Load version
############################################################

if [ -f "$VERSION_FILE" ]; then

    VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"

    if [ -z "$VERSION" ]; then
        VERSION="unknown"
    fi

else

    VERSION="unknown"

fi


############################################################
# Load configuration and modules
############################################################

source "$BASE/config.conf"
source "$BASE/modules/utils.sh"
source "$BASE/modules/verify.sh"
source "$BASE/modules/transfer.sh"
source "$BASE/modules/database_cleanup.sh"


############################################################
# Start
############################################################

init_log

info "==============================================="
info " Frigate Archive V${VERSION} Starting"
info "==============================================="


############################################################
# Configuration
############################################################

info "Loading configuration..."

info "Recording Path : $SOURCE"
info "Archive Path   : $ARCHIVE"
info "Container      : $CONTAINER"

success "Configuration loaded."


############################################################
# System checks
############################################################

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


if command -v docker >/dev/null 2>&1; then

    success "Docker available"

else

    error "Docker unavailable"

    exit 1

fi


if command -v rsync >/dev/null 2>&1; then

    success "rsync available"

else

    error "rsync unavailable"

    exit 1

fi


if docker ps -a --format '{{.Names}}' |
   grep -Fxq "$CONTAINER"; then

    success "Frigate container exists"

else

    error "Frigate container missing"

    exit 1

fi


USAGE=$(
    df -P "$SOURCE" |
    awk 'NR==2 {gsub("%","",$5); print $5}'
)


if ! [[ "$USAGE" =~ ^[0-9]+$ ]]; then

    error "Unable to determine recording drive usage."

    exit 1

fi


info "Recording drive usage: ${USAGE}%"

success "All checks passed."


############################################################
# Lock
############################################################

if ! acquire_lock; then

    error "Unable to acquire lock. Exiting."

    exit 1

fi


############################################################
# Archive decision
############################################################

if [ "$USAGE" -lt "$START_THRESHOLD" ]; then

    info "Archive not required."

    release_lock

    exit 0

fi


info "Archive threshold reached."


############################################################
# Find oldest recording day
############################################################

DAY=$(
    find "$SOURCE" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf "%f\n" |
    sort |
    head -1
)


if [ -z "$DAY" ]; then

    info "No completed recording days available."

    release_lock

    exit 0

fi


info "Archive candidate:"
info "$DAY"


############################################################
# Test mode
############################################################

if [ "$TEST_MODE" = true ]; then

    success "TEST MODE ENABLED"

    info "Source recordings will be preserved."

fi


############################################################
# Pre-transfer verification
############################################################

ARCHIVE_DAY="$ARCHIVE/$DAY"


if [ -d "$ARCHIVE_DAY" ]; then

    info "Existing archive found."
    info "Running pre-transfer verification."

    if ! verify_archive "$DAY"; then

        error "Archive verification failed."

        release_lock

        exit 1

    fi

else

    info "No existing archive found."
    info "Skipping pre-transfer verification."

fi


############################################################
# Transfer
############################################################

if ! archive_transfer "$DAY"; then

    error "Archive transfer stage failed."

    release_lock

    exit 1

fi


success "Archive transfer stage completed."


############################################################
# Database cleanup
############################################################

if ! cleanup_database "$DAY"; then

    error "Database cleanup failed."

    release_lock

    exit 1

fi


success "Database cleanup completed."


############################################################
# Unlock
############################################################

release_lock

success "Frigate Archive V${VERSION} completed successfully."

exit 0
