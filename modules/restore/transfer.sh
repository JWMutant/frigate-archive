#!/bin/bash

############################################################
#
# Frigate Archive
# Restore Transfer Module
#
# Provides:
# - Archive inspection
# - Free-space validation
# - Existing destination detection
# - Restore preview and confirmation
# - Safe rsync transfer
#
############################################################

inspect_restore_archive()
{
    restore_info "Inspecting archived date: $SELECTED_DAY"

    if [ -z "$ARCHIVE_DAY" ] || [ ! -d "$ARCHIVE_DAY" ]; then
        restore_error "Selected archive directory does not exist:"
        restore_error "$ARCHIVE_DAY"
        return 1
    fi

    ARCHIVE_FILE_COUNT=$(
        find "$ARCHIVE_DAY" -type f 2>/dev/null | wc -l
    )

    ARCHIVE_DIR_COUNT=$(
        find "$ARCHIVE_DAY" -mindepth 1 -type d 2>/dev/null | wc -l
    )

    ARCHIVE_BYTES=$(
        du -sb "$ARCHIVE_DAY" 2>/dev/null | awk '{print $1}'
    )

    if ! [[ "$ARCHIVE_FILE_COUNT" =~ ^[0-9]+$ ]] ||
       [ "$ARCHIVE_FILE_COUNT" -eq 0 ]; then
        restore_error "The selected archive contains no usable files."
        return 1
    fi

    if ! [[ "$ARCHIVE_DIR_COUNT" =~ ^[0-9]+$ ]]; then
        restore_error "Unable to determine archived folder count."
        return 1
    fi

    if ! [[ "$ARCHIVE_BYTES" =~ ^[0-9]+$ ]]; then
        restore_error "Unable to determine archive size."
        return 1
    fi

    restore_success "Archive inspection complete."

    return 0
}

calculate_restore_space()
{
    FREE_BYTES=$(
        df -PB1 "$SOURCE" | awk 'NR==2 {print $4}'
    )

    if ! [[ "$FREE_BYTES" =~ ^[0-9]+$ ]]; then
        restore_error "Unable to determine recording-drive free space."
        return 1
    fi

    if ! [[ "$RESTORE_SAFETY_MARGIN_PERCENT" =~ ^[0-9]+$ ]]; then
        restore_error "RESTORE_SAFETY_MARGIN_PERCENT is invalid."
        return 1
    fi

    REQUIRED_BYTES=$(
        (
            ARCHIVE_BYTES +
            (
                ARCHIVE_BYTES *
                RESTORE_SAFETY_MARGIN_PERCENT /
                100
            )
        )
    )

    if [ "$FREE_BYTES" -lt "$REQUIRED_BYTES" ]; then
        restore_error "Insufficient free space on the recording drive."
        restore_error "Archive size : $(restore_human_bytes "$ARCHIVE_BYTES")"
        restore_error "Required     : $(restore_human_bytes "$REQUIRED_BYTES")"
        restore_error "Available    : $(restore_human_bytes "$FREE_BYTES")"
        return 1
    fi

    restore_success "Sufficient free space is available."

    return 0
}

inspect_restore_destination()
{
    RESTORE_DESTINATION_EXISTS=false
    EXISTING_FILE_COUNT=0

    if [ -d "$RESTORE_DAY" ]; then
        RESTORE_DESTINATION_EXISTS=true

        EXISTING_FILE_COUNT=$(
            find "$RESTORE_DAY" -type f 2>/dev/null | wc -l
        )

        if ! [[ "$EXISTING_FILE_COUNT" =~ ^[0-9]+$ ]]; then
            restore_error "Unable to inspect the existing destination."
            return 1
        fi
    fi

    return 0
}

display_restore_preview()
{
    echo
    echo "============================================================"
    echo " Restore Preview"
    echo "============================================================"
    echo
    echo "Selected date"
    echo "------------------------------------------------------------"
    echo "Date                : $SELECTED_DAY"
    echo "Archive size        : $(restore_human_bytes "$ARCHIVE_BYTES")"
    echo "Files               : $ARCHIVE_FILE_COUNT"
    echo "Folders             : $ARCHIVE_DIR_COUNT"
    echo
    echo "Archive source"
    echo "------------------------------------------------------------"
    echo "$ARCHIVE_DAY"
    echo
    echo "Restore destination"
    echo "------------------------------------------------------------"
    echo "$RESTORE_DAY"
    echo

    if [ "$RESTORE_DESTINATION_EXISTS" = true ]; then
        echo "Destination exists  : Yes"
        echo "Existing files      : $EXISTING_FILE_COUNT"
        echo "Destination action  : Merge without deleting files"
    else
        echo "Destination exists  : No"
        echo "Destination action  : Create new date directory"
    fi

    echo
    echo "Storage"
    echo "------------------------------------------------------------"
    echo "Recording free      : $(restore_human_bytes "$FREE_BYTES")"
    echo "Safety margin       : ${RESTORE_SAFETY_MARGIN_PERCENT}%"
    echo "Required space      : $(restore_human_bytes "$REQUIRED_BYTES")"
    echo
    echo "Actions"
    echo "------------------------------------------------------------"
    echo "  ✓ Create or reuse the destination directory"
    echo "  ✓ Copy archived recordings with rsync"
    echo "  ✓ Checksum-verify the restored files"
    echo "  ✓ Preserve the original archive copy"
    echo
    echo "Limitations"
    echo "------------------------------------------------------------"
    echo "  • Frigate database records are not restored."
    echo "  • Timeline and Review entries are not restored."
    echo "  • Restored files may not appear in Frigate's interface."
    echo
    echo "============================================================"
    echo
}

confirm_restore_preview()
{
    local choice

    echo "  1) Restore this date"
    echo "  2) Choose another date"
    echo "  q) Cancel"
    echo

    read -rp "Select an option: " choice

    case "$choice" in
        1)
            RESTORE_CONFIRMED=true
            restore_success "Restore confirmed."
            return 0
            ;;

        2)
            RESTORE_CONFIRMED=false
            restore_info "Returning to the archived-date menu."
            return 3
            ;;

        q|Q)
            RESTORE_CONFIRMED=false
            restore_info "Restore cancelled."
            return 2
            ;;

        *)
            restore_error "Invalid selection."
            return 1
            ;;
    esac
}

prepare_restore_destination()
{
    if ! mkdir -p "$RESTORE_DAY"; then
        restore_error "Unable to create restore destination:"
        restore_error "$RESTORE_DAY"
        return 1
    fi

    if [ ! -w "$RESTORE_DAY" ]; then
        restore_error "Restore destination is not writable:"
        restore_error "$RESTORE_DAY"
        return 1
    fi

    restore_success "Restore destination is ready."

    return 0
}

run_restore_rsync()
{
    restore_info "Starting recording restore..."
    restore_info "The archive copy will be preserved."

    if [ -n "$RESTORE_LOG" ]; then
        rsync \
            -aH \
            --human-readable \
            --info=progress2 \
            "$ARCHIVE_DAY/" \
            "$RESTORE_DAY/" \
            2>&1 |
        tee -a "$RESTORE_LOG"

        local rsync_status=${PIPESTATUS[0]}
    else
        rsync \
            -aH \
            --human-readable \
            --info=progress2 \
            "$ARCHIVE_DAY/" \
            "$RESTORE_DAY/"

        local rsync_status=$?
    fi

    echo

    if [ "$rsync_status" -ne 0 ]; then
        restore_error "rsync restore failed."
        restore_error "rsync status: $rsync_status"
        return 1
    fi

    RESTORE_TRANSFER_COMPLETE=true

    restore_success "File transfer completed."

    return 0
}

prepare_restore_transfer()
{
    local preview_status

    if ! inspect_restore_archive; then
        return 1
    fi

    if ! calculate_restore_space; then
        return 1
    fi

    if ! inspect_restore_destination; then
        return 1
    fi

    display_restore_preview

    confirm_restore_preview
    preview_status=$?

    case "$preview_status" in
        0)
            ;;
        2)
            return 2
            ;;
        3)
            return 3
            ;;
        *)
            return 1
            ;;
    esac

    if ! create_restore_log "$SELECTED_DAY"; then
        return 1
    fi

    if ! prepare_restore_destination; then
        return 1
    fi

    return 0
}

perform_restore_transfer()
{
    if [ "$RESTORE_CONFIRMED" != true ]; then
        restore_error "Restore has not been confirmed."
        return 1
    fi

    if ! run_restore_rsync; then
        return 1
    fi

    return 0
}
