#!/bin/bash

############################################
# Frigate Archive
# Transfer Module
############################################

archive_transfer()
{

DAY="$1"

if [ -z "$DAY" ]; then
    error "No archive day supplied."
    return 1
fi


SOURCE_DAY="$SOURCE/$DAY"
ARCHIVE_DAY="$ARCHIVE/$DAY"


info "Preparing archive transfer:"
info "$DAY"


############################################
# Source exists?
############################################

if [ ! -d "$SOURCE_DAY" ]; then
    error "Source folder not found:"
    info "$SOURCE_DAY"
    return 1
fi


############################################
# Create destination
############################################

mkdir -p "$ARCHIVE_DAY"

if [ $? -ne 0 ]; then
    error "Unable to create archive folder."
    return 1
fi


############################################
# Count source files
############################################

SOURCE_FILES=$(find "$SOURCE_DAY" -type f | wc -l)

info "Source contains $SOURCE_FILES files."


############################################
# Transfer
############################################

info "Starting rsync..."


rsync \
    -aH \
    --human-readable \
    --info=progress2 \
    "$SOURCE_DAY/" \
    "$ARCHIVE_DAY/"


RSYNC_STATUS=$?


echo


if [ $RSYNC_STATUS -ne 0 ]; then

    error "rsync failed."
    return 1

fi


success "Transfer complete."


############################################
# Verify archive
############################################

info "Running archive verification..."


if declare -f verify_archive >/dev/null
then

    verify_archive "$DAY"

    VERIFY_STATUS=$?

else

    error "Verification module not loaded."
    return 1

fi


if [ $VERIFY_STATUS -ne 0 ]; then

    error "Archive verification failed."
    return 1

fi


success "Archive verification passed."


############################################
# Report sizes
############################################

SOURCE_SIZE=$(du -sh "$SOURCE_DAY" | awk '{print $1}')
ARCHIVE_SIZE=$(du -sh "$ARCHIVE_DAY" | awk '{print $1}')


info "Transfer summary:"
info "Source Size  : $SOURCE_SIZE"
info "Archive Size : $ARCHIVE_SIZE"



############################################
# Delete originals
############################################


if [ "$TEST_MODE" = true ]; then

    success "TEST MODE - source files preserved."

else


    info "Removing source recordings..."


    rm -rf "$SOURCE_DAY"


    if [ $? -ne 0 ]; then

        error "Unable to remove source recordings."
        return 1

    fi


    success "Source recordings removed."

fi


return 0

}
