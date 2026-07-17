#!/bin/bash

############################################################
#
# Frigate Archive Restore Wizard
#
# Author  : Jonathan Dalcin
# License : MIT
#
############################################################

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTORE_MODULE_DIR="$PROJECT_DIR/modules/restore"
RESTORE_CORE_DIR="$RESTORE_MODULE_DIR/core"

REQUIRED_RESTORE_MODULES=(
    "$RESTORE_CORE_DIR/context.sh"
    "$RESTORE_CORE_DIR/logging.sh"
    "$RESTORE_CORE_DIR/checks.sh"
    "$RESTORE_MODULE_DIR/menu.sh"
    "$RESTORE_MODULE_DIR/transfer.sh"
    "$RESTORE_MODULE_DIR/verify.sh"
)

for module_file in "${REQUIRED_RESTORE_MODULES[@]}"
do
    if [ ! -f "$module_file" ]; then
        echo "[ERROR] Required Restore module is missing:"
        echo "[ERROR] $module_file"
        exit 1
    fi

    if ! bash -n "$module_file" >/dev/null 2>&1; then
        echo "[ERROR] Restore module contains a syntax error:"
        echo "[ERROR] $module_file"
        exit 1
    fi
done

# shellcheck disable=SC1091
source "$RESTORE_CORE_DIR/context.sh"
source "$RESTORE_CORE_DIR/logging.sh"
source "$RESTORE_CORE_DIR/checks.sh"
source "$RESTORE_MODULE_DIR/menu.sh"
source "$RESTORE_MODULE_DIR/transfer.sh"
source "$RESTORE_MODULE_DIR/verify.sh"

reset_restore_context
load_restore_version
install_restore_traps

restore_header

if ! run_restore_checks; then
    restore_error "Restore startup checks failed."
    exit 1
fi

REQUESTED_DAY="${1:-}"

while true
do
    ########################################################
    # Reset date-specific state before each menu cycle
    ########################################################

    SELECTED_DAY=""
    ARCHIVE_DAY=""
    RESTORE_DAY=""

    ARCHIVE_FILE_COUNT=0
    ARCHIVE_DIR_COUNT=0
    ARCHIVE_BYTES=0

    EXISTING_FILE_COUNT=0
    RESTORED_FILE_COUNT=0
    RESTORED_BYTES=0

    FREE_BYTES=0
    REQUIRED_BYTES=0

    RESTORE_DESTINATION_EXISTS=false
    RESTORE_CONFIRMED=false
    RESTORE_TRANSFER_COMPLETE=false
    RESTORE_VERIFICATION_COMPLETE=false

    ########################################################
    # Select archived date
    ########################################################

    select_restore_date "$REQUESTED_DAY"
    selection_status=$?

    REQUESTED_DAY=""

    if [ "$selection_status" -eq 2 ]; then
        exit 0
    fi

    if [ "$selection_status" -ne 0 ]; then
        restore_error "Unable to select a restore date."
        exit 1
    fi

    ########################################################
    # Preview and prepare
    ########################################################

    prepare_restore_transfer
    prepare_status=$?

    if [ "$prepare_status" -eq 2 ]; then
        exit 0
    fi

    if [ "$prepare_status" -eq 3 ]; then
        continue
    fi

    if [ "$prepare_status" -ne 0 ]; then
        restore_error "Unable to prepare the restore."
        exit 1
    fi

    break
done

if ! perform_restore_transfer; then
    restore_error "Restore transfer failed."
    exit 1
fi

if ! verify_restore; then
    restore_error "Restore verification failed."
    exit 1
fi

restore_success "Frigate Archive Restore Wizard completed successfully."

exit 0
