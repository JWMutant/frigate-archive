#!/bin/bash

############################################################
#
# Frigate Archive Uninstaller
#
# Version : 2.1.0
# Author  : Jonathan Dalcin
# License : MIT
#
############################################################

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_FILE="$PROJECT_DIR/config.conf"
LOG_DIR="$PROJECT_DIR/logs"
BACKUP_DIR="$PROJECT_DIR/backups"

echo
echo "============================================================"
echo " Frigate Archive Uninstaller"
echo "============================================================"
echo

echo "This utility removes Frigate Archive runtime files."
echo
echo "The following WILL NOT be touched:"
echo
echo "  - Frigate Docker container"
echo "  - Frigate recordings"
echo "  - Archived recordings"
echo "  - Frigate database"
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
echo "Cleaning runtime files..."

############################################################
# Remove logs
############################################################

if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -type f ! -name ".gitkeep" -delete
    echo "Logs removed."
fi

############################################################
# Remove backups
############################################################

if [ -d "$BACKUP_DIR" ]; then
    find "$BACKUP_DIR" -type f ! -name ".gitkeep" -delete
    echo "Database backups removed."
fi

############################################################
# Remove lock file
############################################################

rm -f /tmp/frigate_archive*.lock

echo "Lock files removed."

############################################################
# Configuration
############################################################

if [ -f "$CONFIG_FILE" ]; then

    echo

    read -rp "Remove config.conf? (y/N): " REMOVE_CONFIG

    case "$REMOVE_CONFIG" in
        y|Y|yes|YES)
            rm -f "$CONFIG_FILE"
            echo "Configuration removed."
            ;;
        *)
            echo "Configuration preserved."
            ;;
    esac

fi

echo
echo "============================================================"
echo " Uninstall Complete"
echo "============================================================"
echo
echo "The project files remain on disk."
echo
echo "To completely remove Frigate Archive simply delete:"
echo
echo "  $PROJECT_DIR"
echo
echo "Your recordings and Frigate installation have NOT been modified."
echo
