############################################
# Frigate Archive
# Verification Module
############################################


verify_archive()
{

DAY="$1"


if [ -z "$DAY" ]; then

    error "No archive day supplied."
    return 1

fi


SOURCE_DAY="$SOURCE/$DAY"
ARCHIVE_DAY="$ARCHIVE/$DAY"


info "Verifying archive:"
info "$DAY"



############################################
# Check folders exist
############################################


if [ ! -d "$SOURCE_DAY" ]; then

    error "Source folder not found:"
    info "$SOURCE_DAY"

    return 1

fi



if [ ! -d "$ARCHIVE_DAY" ]; then

    error "Archive folder not found:"
    info "$ARCHIVE_DAY"

    return 1

fi



############################################
# Basic statistics
############################################


SOURCE_FILES=$(find "$SOURCE_DAY" -type f | wc -l)

ARCHIVE_FILES=$(find "$ARCHIVE_DAY" -type f | wc -l)


SOURCE_SIZE=$(du -sb "$SOURCE_DAY" | awk '{print $1}')

ARCHIVE_SIZE=$(du -sb "$ARCHIVE_DAY" | awk '{print $1}')


info "Source files : $SOURCE_FILES"

info "Archive files: $ARCHIVE_FILES"


info "Source bytes : $SOURCE_SIZE"

info "Archive bytes: $ARCHIVE_SIZE"



############################################
# Archive logic check
############################################
#
# Archive is allowed to be larger.
# We only fail if the archive is missing
# files that exist in the source.
#
############################################


if [ "$ARCHIVE_FILES" -lt "$SOURCE_FILES" ]; then

    error "Archive contains fewer files than source."

fi



############################################
# Deep verification
############################################


info "Running archive integrity verification..."



RSYNC_OUTPUT=$(
rsync -an \
"$SOURCE_DAY/" \
"$ARCHIVE_DAY/"
)



if [ -z "$RSYNC_OUTPUT" ]; then


    success "Archive integrity verification passed."

    return 0


fi



############################################
# Report missing files
############################################


info "Files missing from archive:"


echo "$RSYNC_OUTPUT" | while read -r LINE
do

    info "$LINE"

done



error "Archive integrity verification failed."


return 1


}
