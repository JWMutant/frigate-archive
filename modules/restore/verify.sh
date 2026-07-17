#!/bin/bash

############################################################
#
# Frigate Archive
# Restore Verification Module
#
# Provides:
# - Checksum verification
# - Restored file statistics
# - Final restore summary
#
############################################################

############################################################
# Verify restored files
############################################################

verify_restored_files()
{
    restore_info "Running checksum verification..."
    restore_info "This may take some time for a large archive."

    local verify_output
    local verify_status

    verify_output=$(
        rsync \
            -aHnc \
            --dry-run \
            --itemize-changes \
            "$ARCHIVE_DAY/" \
            "$RESTORE_DAY/" \
            2>&1
    )

    verify_status=$?

    if [ "$verify_status" -ne 0 ]; then

        restore_error "Restore verification command failed."
        restore_error "rsync status: $verify_status"

        if [ -n "$verify_output" ]; then

            printf '%s\n' "$verify_output"

            if [ -n "$RESTORE_LOG" ]; then
                printf '%s\n' "$verify_output" >> "$RESTORE_LOG"
            fi

        fi

        return 1
    fi

    if [ -n "$verify_output" ]; then

        restore_error "Restore verification detected differences."

        printf '%s\n' "$verify_output"

        if [ -n "$RESTORE_LOG" ]; then
            printf '%s\n' "$verify_output" >> "$RESTORE_LOG"
        fi

        return 1
    fi

    RESTORE_VERIFICATION_COMPLETE=true

    restore_success "Checksum verification passed."

    return 0
}

############################################################
# Collect restored destination statistics
############################################################

collect_restored_statistics()
{
    if [ ! -d "$RESTORE_DAY" ]; then

        restore_error "Restore destination does not exist:"
        restore_error "$RESTORE_DAY"

        return 1
    fi

    RESTORED_FILE_COUNT=$(
        find "$RESTORE_DAY" \
            -type f \
            2>/dev/null |
        wc -l
    )

    RESTORED_BYTES=$(
        du -sb "$RESTORE_DAY" \
            2>/dev/null |
        awk '{print $1}'
    )

    if ! [[ "$RESTORED_FILE_COUNT" =~ ^[0-9]+$ ]]; then

        restore_error "Unable to determine restored file count."

        return 1
    fi

    if ! [[ "$RESTORED_BYTES" =~ ^[0-9]+$ ]]; then

        restore_error "Unable to determine restored destination size."

        return 1
    fi

    restore_success "Restored destination statistics collected."

    return 0
}

############################################################
# Validate restored file count
############################################################

validate_restored_file_count()
{
    if [ "$RESTORE_DESTINATION_EXISTS" = false ]; then

        if [ "$RESTORED_FILE_COUNT" -ne "$ARCHIVE_FILE_COUNT" ]; then

            restore_error "Restored file count does not match the archive."
            restore_error "Archive files     : $ARCHIVE_FILE_COUNT"
            restore_error "Destination files : $RESTORED_FILE_COUNT"

            return 1
        fi

        restore_success "Restored file count matches the archive."

    else

        if [ "$RESTORED_FILE_COUNT" -lt "$ARCHIVE_FILE_COUNT" ]; then

            restore_error "Destination contains fewer files than the archive."
            restore_error "Archive files     : $ARCHIVE_FILE_COUNT"
            restore_error "Destination files : $RESTORED_FILE_COUNT"

            return 1
        fi

        restore_success "Destination contains all archived files."

    fi

    return 0
}

############################################################
# Validate restored destination size
############################################################

validate_restored_size()
{
    if [ "$RESTORE_DESTINATION_EXISTS" = false ]; then

        if [ "$RESTORED_BYTES" -ne "$ARCHIVE_BYTES" ]; then

            restore_error "Restored size does not match the archive."
            restore_error "Archive size     : $(restore_human_bytes "$ARCHIVE_BYTES")"
            restore_error "Destination size : $(restore_human_bytes "$RESTORED_BYTES")"

            return 1
        fi

        restore_success "Restored size matches the archive."

    else

        if [ "$RESTORED_BYTES" -lt "$ARCHIVE_BYTES" ]; then

            restore_error "Destination size is smaller than the archive."
            restore_error "Archive size     : $(restore_human_bytes "$ARCHIVE_BYTES")"
            restore_error "Destination size : $(restore_human_bytes "$RESTORED_BYTES")"

            return 1
        fi

        restore_success "Destination size includes the archived content."

    fi

    return 0
}

############################################################
# Write completion details to log
############################################################

write_restore_completion_log()
{
    if [ -z "$RESTORE_LOG" ]; then
        return 0
    fi

    {
        echo
        echo "============================================================"
        echo "Restore completed successfully"
        echo "Completed: $(date --iso-8601=seconds)"
        echo "============================================================"
        echo "Restored date      : $SELECTED_DAY"
        echo "Archive files      : $ARCHIVE_FILE_COUNT"
        echo "Destination files  : $RESTORED_FILE_COUNT"
        echo "Archive size       : $(restore_human_bytes "$ARCHIVE_BYTES")"
        echo "Destination size   : $(restore_human_bytes "$RESTORED_BYTES")"
        echo "Verification       : PASSED"
        echo "Archive copy       : PRESERVED"
        echo "Database metadata  : NOT RESTORED"
    } >> "$RESTORE_LOG"

    return 0
}

############################################################
# Display final restore summary
############################################################

display_restore_summary()
{
    echo
    echo "============================================================"
    echo " Restore Complete"
    echo " Frigate Archive $VERSION"
    echo "============================================================"
    echo
    echo "Restored date      : $SELECTED_DAY"
    echo "Archive files      : $ARCHIVE_FILE_COUNT"
    echo "Destination files  : $RESTORED_FILE_COUNT"
    echo "Archive size       : $(restore_human_bytes "$ARCHIVE_BYTES")"
    echo "Destination size   : $(restore_human_bytes "$RESTORED_BYTES")"
    echo "Verification       : PASSED"
    echo "Archive copy       : PRESERVED"
    echo "Database metadata  : NOT RESTORED"
    echo "Restore log        : $RESTORE_LOG"
    echo

    restore_warning "The restored files may not appear in Frigate's interface"
    restore_warning "because their original database records were removed."

    return 0
}

############################################################
# Main verification entry point
############################################################

verify_restore()
{
    if [ "$RESTORE_TRANSFER_COMPLETE" != true ]; then

        restore_error "Restore transfer has not completed."

        return 1
    fi

    if ! verify_restored_files; then
        return 1
    fi

    if ! collect_restored_statistics; then
        return 1
    fi

    if ! validate_restored_file_count; then
        return 1
    fi

    if ! validate_restored_size; then
        return 1
    fi

    write_restore_completion_log

    display_restore_summary

    RESTORE_SUCCESS=true

    return 0
}
