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

############################################################
# Load version
############################################################

if [ -f "$VERSION_FILE" ]; then
    VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
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

command -v bash >/dev/null 2>&1 ||
    fail "bash is not available."

command -v docker >/dev/null 2>&1 ||
    fail "Docker is not available."

command -v rsync >/dev/null 2>&1 ||
    fail "rsync is not available."

command -v find >/dev/null 2>&1 ||
    fail "find is not available."

command -v awk >/dev/null 2>&1 ||
    fail "awk is not available."

command -v sed >/dev/null 2>&1 ||
    fail "sed is not available."

pass "Required commands are available."

############################################################
# Validate project files
############################################################

[ -f "$PROJECT_DIR/archive.sh" ] ||
    fail "archive.sh is missing."

[ -f "$VERSION_FILE" ] ||
    fail "VERSION file is missing."

[ -f "$CONFIG_EXAMPLE" ] ||
    fail "config.conf.example is missing."

[ -d "$MODULE_DIR" ] ||
    fail "modules directory is missing."

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
# Normalize line endings
############################################################

find "$PROJECT_DIR" \
    -maxdepth 2 \
    -type f \
    \( -name "*.sh" -o -name "*.conf" -o -name "*.example" \) \
    -exec sed -i 's/\r$//' {} \;

pass "Line endings normalized."

############################################################
# Set permissions where supported
############################################################

chmod +x "$PROJECT_DIR/archive.sh" 2>/dev/null || true
chmod +x "$PROJECT_DIR/install.sh" 2>/dev/null || true

if [ -f "$PROJECT_DIR/uninstall.sh" ]; then
    chmod +x "$PROJECT_DIR/uninstall.sh" 2>/dev/null || true
fi

if [ -f "$PROJECT_DIR/healthcheck.sh" ]; then
    chmod +x "$PROJECT_DIR/healthcheck.sh" 2>/dev/null || true
fi

find "$MODULE_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.sh" \
    -exec chmod +x {} \; 2>/dev/null || true

if [[ "$PROJECT_DIR" == /boot/* ]]; then
    note "Project is stored on the Unraid FAT boot filesystem."
    note "Use 'bash script-name.sh' to run project scripts."
else
    pass "Script permissions set."
fi

############################################################
# Validate shell syntax
############################################################

if ! bash -n "$PROJECT_DIR/archive.sh"; then
    fail "archive.sh contains a syntax error."
fi

while IFS= read -r module
do
    if ! bash -n "$module"; then
        fail "Syntax error in $module"
    fi
done < <(
    find "$MODULE_DIR" \
        -maxdepth 1 \
        -type f \
        -name "*.sh" \
        | sort
)

if ! bash -n "$CONFIG_FILE"; then
    fail "config.conf contains a syntax error."
fi

pass "Shell syntax checks passed."

############################################################
# Load and inspect configuration
############################################################

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [ -z "${SOURCE:-}" ]; then
    fail "SOURCE is not configured."
fi

if [ -z "${ARCHIVE:-}" ]; then
    fail "ARCHIVE is not configured."
fi

if [ -z "${CONTAINER:-}" ]; then
    fail "CONTAINER is not configured."
fi

if [ -z "${FRIGATE_DB:-}" ]; then
    fail "FRIGATE_DB is not configured."
fi

pass "Required configuration values are present."

############################################################
# Check Frigate container
############################################################

if docker ps -a --format '{{.Names}}' |
    grep -Fxq "$CONTAINER"; then

    pass "Frigate container found: $CONTAINER"

else

    note "Frigate container '$CONTAINER' was not found."
    note "Update CONTAINER in config.conf if your container uses another name."

fi

############################################################
# Check configured paths
############################################################

if [ -d "$SOURCE" ]; then
    pass "Recording path exists: $SOURCE"
else
    note "Recording path does not currently exist: $SOURCE"
fi

if [ -d "$ARCHIVE" ]; then
    pass "Archive path exists: $ARCHIVE"
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
echo "2. Keep TEST_MODE=true for the first test."
echo
echo "3. Run the health check:"
echo "   bash $PROJECT_DIR/healthcheck.sh"
echo
echo "4. Run the archive manually:"
echo "   bash $PROJECT_DIR/archive.sh"
echo
echo "5. Review the output and logs."
echo
echo "6. When satisfied, set TEST_MODE=false."
echo
echo "7. Schedule it in the Unraid User Scripts plugin."
echo
echo "   Recommended cron schedule: 0 2 * * *"
echo
