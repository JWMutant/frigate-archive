#!/bin/bash

############################################################
#
# Frigate Archive
# Restore Context Module
#
# Defines the shared state used by the Restore Wizard.
#
# This module does not perform any work by itself.
# It only initializes and documents variables shared between
# restore checks, menu, transfer, verification, and controller.
#
############################################################

############################################################
# Selection and paths
############################################################

SELECTED_DAY=""

ARCHIVE_DAY=""
RESTORE_DAY=""

############################################################
# Archive statistics
############################################################

ARCHIVE_FILE_COUNT=0
ARCHIVE_DIR_COUNT=0
ARCHIVE_BYTES=0

############################################################
# Destination statistics
############################################################

EXISTING_FILE_COUNT=0
RESTORED_FILE_COUNT=0
RESTORED_BYTES=0

############################################################
# Storage calculations
############################################################

FREE_BYTES=0
REQUIRED_BYTES=0

RESTORE_SAFETY_MARGIN_PERCENT=5

############################################################
# Restore state
############################################################

RESTORE_DESTINATION_EXISTS=false
RESTORE_CONFIRMED=false
RESTORE_TRANSFER_COMPLETE=false
RESTORE_VERIFICATION_COMPLETE=false

############################################################
# Runtime and logging
############################################################

RESTORE_LOCK="${RESTORE_LOCK:-/tmp/frigate_archive_restore.lock}"
RESTORE_LOG_DIR="${RESTORE_LOG_DIR:-$PROJECT_DIR/logs}"
RESTORE_LOG=""

LOCK_ACQUIRED=false
RESTORE_SUCCESS=false

############################################################
# Reset restore context
############################################################

reset_restore_context()
{
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

    RESTORE_LOG=""

    LOCK_ACQUIRED=false
    RESTORE_SUCCESS=false
}
