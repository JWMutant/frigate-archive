#!/bin/bash

############################################################
#
# Frigate Archive Uninstaller
#
# Author  : Jonathan Dalcin
# License : MIT
#
############################################################

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$PROJECT_DIR/VERSION"

CONFIG_FILE="$PROJECT_DIR/config.conf"
LOG_DIR="$PROJECT_DIR/logs"
BACKUP_DIR="$PROJECT_DIR/backups"

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

echo
echo "============================================================"
echo " Frigate Archive Uninstaller"
echo " Version $VERSION"
echo "============================================================"
echo

echo "This utility removes Frigate Archive runtime files."
echo "This includes runtime files used by both the Archive Engine"
echo "and the Restore Wizard."
echo
echo "The following WILL NOT be touched:"
echo
echo "  - Frigate Docker container"
echo "  - Frigate recordings"
echo "  - Archived recordings"
echo "  - Frigate database"
echo "  - Archive Engine source code"
echo "  - Restore Wizard source code"
echo "  - Project source code"
echo

read -rp "Continue? (y/N): " ANSWER

case "$ANSWER" in
    y|Y|yes|YES)
        ;;
    *)
        echo
        echo "Cancelled."
        exit 0
        ;;
esac

echo
echo "Scanning runtime files..."

############################################################
# Count runtime files
############################################################

LOG_COUNT=0
BACKUP_COUNT=0
LOCK_COUNT=0

if [ -d "$LOG_DIR" ]; then

    LOG_COUNT=$(
        find "$LOG_DIR" \
            -maxdepth 1 \
            -type f \
            ! -name ".gitkeep" \
            2>/dev/null |
        wc -l
    )

fi

if [ -d "$BACKUP_DIR" ]; then

    BACKUP_COUNT=$(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            ! -name ".gitkeep" \
            2>/dev/null |
        wc -l
    )

fi

LOCK_COUNT=$(
    find /tmp \
        -maxdepth 1 \
        -type f \
        -name 'frigate_archive*.lock' \
        2>/dev/null |
    wc -l
)

echo "Archive/Restore logs found : $LOG_COUNT"
echo "Project backups found      : $BACKUP_COUNT"
echo "Archive/Restore locks found: $LOCK_COUNT"

echo
echo "Cleaning runtime files..."

############################################################
# Remove Archive and Restore logs
############################################################

if [ -d "$LOG_DIR" ]; then

    find "$LOG_DIR" \
        -maxdepth 1 \
        -type f \
        ! -name ".gitkeep" \
        -delete

fi

############################################################
# Remove project backups
############################################################

if [ -d "$BACKUP_DIR" ]; then

    find "$BACKUP_DIR" \
        -maxdepth 1 \
        -type f \
        ! -name ".gitkeep" \
        -delete

fi

############################################################
# Remove Archive and Restore lock files
############################################################

find /tmp \
    -maxdepth 1 \
    -type f \
    -name 'frigate_archive*.lock' \
    -delete 2>/dev/null

############################################################
# Configuration
############################################################

CONFIG_STATUS="Not present"

if [ -f "$CONFIG_FILE" ]; then

    echo
    echo "config.conf is shared by the Archive Engine and Restore Wizard."

    read -rp "Remove the shared config.conf? (y/N): " REMOVE_CONFIG

    case "$REMOVE_CONFIG" in
        y|Y|yes|YES)

            rm -f "$CONFIG_FILE"

            if [ -f "$CONFIG_FILE" ]; then
                CONFIG_STATUS="Removal failed"
            else
                CONFIG_STATUS="Removed"
            fi
            ;;

        *)

            CONFIG_STATUS="Preserved"
            ;;

    esac

fi

############################################################
# Summary
############################################################

echo
echo "============================================================"
echo " Uninstall Summary"
echo " Frigate Archive $VERSION"
echo "============================================================"
echo
echo "Archive/Restore logs removed : $LOG_COUNT"
echo "Project backups removed      : $BACKUP_COUNT"
echo "Archive/Restore locks removed: $LOCK_COUNT"
echo "Configuration                : $CONFIG_STATUS"
echo "Project source code          : Preserved"
echo "Archive Engine               : Preserved"
echo "Restore Wizard               : Preserved"
echo "Frigate container            : Preserved"
echo "Frigate database             : Preserved"
echo "Live recordings              : Preserved"
echo "Archived recordings          : Preserved"
echo
echo "The project files remain at:"
echo
echo "  $PROJECT_DIR"
echo
echo "To remove the project completely, manually delete that"
echo "directory only after confirming you no longer need it."
echo
