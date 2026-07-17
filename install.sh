#!/bin/bash

############################################################
#
# Frigate Archive Installer
#
# Author  : Jonathan Dalcin
# License : MIT
#
############################################################

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$PROJECT_DIR/VERSION"
CONFIG_EXAMPLE="$PROJECT_DIR/config.conf.example"
CONFIG_FILE="$PROJECT_DIR/config.conf"
LOG_DIR="$PROJECT_DIR/logs"
BACKUP_DIR="$PROJECT_DIR/backups"
MODULE_DIR="$PROJECT_DIR/modules"
RESTORE_MODULE_DIR="$MODULE_DIR/restore"
RESTORE_CORE_DIR="$RESTORE_MODULE_DIR/core"

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
echo " Frigate Archive Installer"
echo " Version $VERSION"
echo "============================================================"
echo

############################################################
# Helper functions
############################################################

fail()
{
    echo "[ERROR] $1"
    exit 1
}

pass()
{
    echo "[OK] $1"
}

note()
{
    echo "[INFO] $1"
}

############################################################
# Check platform
############################################################

if [ -f /etc/unraid-version ]; then

    pass "Unraid detected."

else

    note "Unraid was not positively detected."
    note "Installation can continue, but this project is designed for Unraid."

fi

############################################################
# Check required commands
############################################################

REQUIRED_COMMANDS=(
    awk
    bash
    date
    df
    docker
    du
    find
    grep
    mkdir
    numfmt
    rsync
    sed
    sort
    tee
    touch
    tr
    wc
)

for command_name in "${REQUIRED_COMMANDS[@]}"
do
    if command -v "$command_name" >/dev/null 2>&1; then

        pass "$command_name is available."

    else

        fail "$command_name is not available."

    fi
done

pass "Required commands are available."

############################################################
# Validate main project files
############################################################

REQUIRED_PROJECT_FILES=(
    "$PROJECT_DIR/archive.sh"
    "$PROJECT_DIR/restore.sh"
    "$PROJECT_DIR/install.sh"
    "$PROJECT_DIR/uninstall.sh"
    "$PROJECT_DIR/healthcheck.sh"
    "$VERSION_FILE"
    "$CONFIG_EXAMPLE"
    "$PROJECT_DIR/README.md"
    "$PROJECT_DIR/CHANGELOG.md"
    "$PROJECT_DIR/LICENSE"
)

for required_file in "${REQUIRED_PROJECT_FILES[@]}"
do
    if [ -f "$required_file" ]; then

        pass "Found: ${required_file#$PROJECT_DIR/}"

    else

        fail "Required project file is missing: $required_file"

    fi
done

############################################################
# Validate directories
############################################################

if [ ! -d "$MODULE_DIR" ]; then
    fail "modules directory is missing."
fi

if [ ! -d "$RESTORE_MODULE_DIR" ]; then
    fail "Restore module directory is missing: $RESTORE_MODULE_DIR"
fi

if [ ! -d "$RESTORE_CORE_DIR" ]; then
    fail "Restore core directory is missing: $RESTORE_CORE_DIR"
fi

pass "Project directories found."

############################################################
# Validate Archive modules
############################################################

REQUIRED_ARCHIVE_MODULES=(
    "$MODULE_DIR/archive.sh"
    "$MODULE_DIR/checks.sh"
    "$MODULE_DIR/database_cleanup.sh"
    "$MODULE_DIR/logging.sh"
    "$MODULE_DIR/notifications.sh"
    "$MODULE_DIR/notify.sh"
    "$MODULE_DIR/transfer.sh"
    "$MODULE_DIR/utils.sh"
    "$MODULE_DIR/verify.sh"
)

for module_file in "${REQUIRED_ARCHIVE_MODULES[@]}"
do
    if [ -f "$module_file" ]; then

        pass "Archive module found: ${module_file#$PROJECT_DIR/}"

    else

        fail "Required Archive module is missing: $module_file"

    fi
done

############################################################
# Validate Restore modules
############################################################

REQUIRED_RESTORE_MODULES=(
    "$RESTORE_CORE_DIR/checks.sh"
    "$RESTORE_CORE_DIR/context.sh"
    "$RESTORE_CORE_DIR/logging.sh"
    "$RESTORE_MODULE_DIR/menu.sh"
    "$RESTORE_MODULE_DIR/transfer.sh"
    "$RESTORE_MODULE_DIR/verify.sh"
)

for module_file in "${REQUIRED_RESTORE_MODULES[@]}"
do
    if [ -f "$module_file" ]; then

        pass "Restore module found: ${module_file#$PROJECT_DIR/}"

    else

        fail "Required Restore module is missing: $module_file"

    fi
done

pass "Project files found."
pass "Project version detected: $VERSION"

############################################################
# Create runtime directories
############################################################

mkdir -p "$LOG_DIR" ||
    fail "Unable to create logs directory."

mkdir -p "$BACKUP_DIR" ||
    fail "Unable to create backups directory."

pass "Runtime directories are ready."

############################################################
# Create local configuration
############################################################

if [ -f "$CONFIG_FILE" ]; then

    note "Existing config.conf found."
    note "It has not been overwritten."

else

    cp "$CONFIG_EXAMPLE" "$CONFIG_FILE" ||
        fail "Unable to create config.conf."

    pass "config.conf created from config.conf.example."
    note "Edit config.conf before the first live run."

fi

############################################################
# Normalize line endings recursively
############################################################

find "$PROJECT_DIR" \
    -type f \
    \( \
        -name "*.sh" \
        -o -name "*.conf" \
        -o -name "*.example" \
        -o -name "*.yml" \
        -o -name "*.yaml" \
        -o -name "VERSION" \
    \) \
    -not -path "$PROJECT_DIR/.git/*" \
    -exec sed -i 's/\r$//' {} \;

pass "Line endings normalized."

############################################################
# Set permissions where supported
############################################################

MAIN_SCRIPTS=(
    "$PROJECT_DIR/archive.sh"
    "$PROJECT_DIR/restore.sh"
    "$PROJECT_DIR/install.sh"
    "$PROJECT_DIR/uninstall.sh"
    "$PROJECT_DIR/healthcheck.sh"
)

for script_file in "${MAIN_SCRIPTS[@]}"
do
    chmod +x "$script_file" 2>/dev/null || true
done

find "$MODULE_DIR" \
    -type f \
    -name "*.sh" \
    -exec chmod +x {} \; \
    2>/dev/null ||
true

if [[ "$PROJECT_DIR" == /boot/* ]]; then

    note "Project is stored on the Unraid FAT boot filesystem."
    note "Linux executable permission bits are not retained on /boot."
    note "Use 'bash script-name.sh' to run project scripts."

else

    pass "Script permissions set."

fi

############################################################
# Validate shell syntax recursively
############################################################

for script_file in "${MAIN_SCRIPTS[@]}"
do
    if bash -n "$script_file"; then

        pass "Syntax valid: ${script_file#$PROJECT_DIR/}"

    else

        fail "Syntax error in $script_file"

    fi
done

while IFS= read -r module_file
do
    if bash -n "$module_file"; then

        pass "Syntax valid: ${module_file#$PROJECT_DIR/}"

    else

        fail "Syntax error in $module_file"

    fi
done < <(
    find "$MODULE_DIR" \
        -type f \
        -name "*.sh" \
        | sort
)

if bash -n "$CONFIG_FILE"; then

    pass "config.conf syntax is valid."

else

    fail "config.conf contains a syntax error."

fi

pass "Shell syntax checks passed."

############################################################
# Load and inspect configuration
############################################################

# shellcheck disable=SC1090
source "$CONFIG_FILE"

REQUIRED_SETTINGS=(
    SOURCE
    ARCHIVE
    CONTAINER
    FRIGATE_DB
    START_THRESHOLD
    STOP_THRESHOLD
    DB_BACKUP_KEEP
    KEEP_LOGS
    LOCKFILE
    LOG_DIR
    LOGFILE
    TEST_MODE
)

for setting in "${REQUIRED_SETTINGS[@]}"
do
    if [ -n "${!setting:-}" ]; then

        pass "$setting is configured."

    else

        fail "$setting is missing or empty."

    fi
done

pass "Required configuration values are present."

############################################################
# Validate threshold values
############################################################

if ! [[ "$START_THRESHOLD" =~ ^[0-9]+$ ]]; then
    fail "START_THRESHOLD must be a whole number."
fi

if ! [[ "$STOP_THRESHOLD" =~ ^[0-9]+$ ]]; then
    fail "STOP_THRESHOLD must be a whole number."
fi

if [ "$START_THRESHOLD" -le "$STOP_THRESHOLD" ]; then
    fail "START_THRESHOLD must be greater than STOP_THRESHOLD."
fi

if [ "$START_THRESHOLD" -lt 1 ] ||
   [ "$START_THRESHOLD" -gt 100 ]; then

    fail "START_THRESHOLD must be between 1 and 100."

fi

if [ "$STOP_THRESHOLD" -lt 0 ] ||
   [ "$STOP_THRESHOLD" -gt 99 ]; then

    fail "STOP_THRESHOLD must be between 0 and 99."

fi

pass "Archive thresholds are valid."

############################################################
# Check Frigate container
############################################################

if docker ps -a --format '{{.Names}}' |
   grep -Fxq "$CONTAINER"; then

    pass "Frigate container found: $CONTAINER"

    CONTAINER_STATE=$(
        docker inspect \
            -f '{{.State.Status}}' \
            "$CONTAINER" \
            2>/dev/null
    )

    if [ "$CONTAINER_STATE" = "running" ]; then

        pass "Frigate container is running."

    else

        note "Frigate container is not currently running."
        note "Current state: ${CONTAINER_STATE:-unknown}"

    fi

else

    note "Frigate container '$CONTAINER' was not found."
    note "Update CONTAINER in config.conf if it uses another name."

fi

############################################################
# Check configured paths
############################################################

if [ -d "$SOURCE" ]; then

    pass "Recording path exists: $SOURCE"

    if [ -w "$SOURCE" ]; then
        pass "Recording path is writable."
    else
        note "Recording path is not writable."
    fi

else

    note "Recording path does not currently exist: $SOURCE"

fi

if [ -d "$ARCHIVE" ]; then

    pass "Archive path exists: $ARCHIVE"

    if [ -r "$ARCHIVE" ]; then
        pass "Archive path is readable."
    else
        note "Archive path is not readable."
    fi

else

    note "Archive path does not currently exist: $ARCHIVE"
    note "Create it or update ARCHIVE in config.conf."

fi

if [ -f "$FRIGATE_DB" ]; then

    pass "Frigate database found: $FRIGATE_DB"

else

    note "Frigate database was not found: $FRIGATE_DB"
    note "Update FRIGATE_DB in config.conf if necessary."

fi

############################################################
# Validate Restore Wizard directly
############################################################

if bash -n "$PROJECT_DIR/restore.sh"; then

    pass "Restore Wizard controller is valid."

else

    fail "Restore Wizard controller contains a syntax error."

fi

pass "Restore Wizard subsystem is installed and valid."

############################################################
# Final instructions
############################################################

echo
echo "============================================================"
echo " Installation complete"
echo " Frigate Archive $VERSION"
echo "============================================================"
echo
echo "Next steps:"
echo
echo "1. Edit the configuration:"
echo "   nano $CONFIG_FILE"
echo
echo "2. Keep TEST_MODE=true for the first archive test."
echo
echo "3. Run the health check:"
echo "   bash $PROJECT_DIR/healthcheck.sh"
echo
echo "4. Test the Archive engine:"
echo "   bash $PROJECT_DIR/archive.sh"
echo
echo "5. Test the Restore Wizard menu:"
echo "   bash $PROJECT_DIR/restore.sh"
echo "   Select q to exit without restoring anything."
echo
echo "6. Review the output and logs."
echo
echo "7. When satisfied, set TEST_MODE=false."
echo
echo "8. Schedule archive.sh in the Unraid User Scripts plugin."
echo
echo "   Recommended cron schedule: 0 2 * * *"
echo
echo "Important:"
echo "The Restore Wizard currently restores recording files only."
echo "It does not recreate removed Frigate database or timeline records."
echo
