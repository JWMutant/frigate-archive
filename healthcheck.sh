#!/bin/bash

############################################################
#
# Frigate Archive Health Check
#
# Version : 2.1.0
# Author  : Jonathan Dalcin
# License : MIT
#
############################################################

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.conf"
MODULE_DIR="$PROJECT_DIR/modules"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

print_header()
{
    echo
    echo "============================================================"
    echo " Frigate Archive Health Check"
    echo "============================================================"
    echo
}

section()
{
    echo
    echo "$1"
    echo "------------------------------------------------------------"
}

pass()
{
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

warn()
{
    echo "[WARN] $1"
    WARN_COUNT=$((WARN_COUNT + 1))
}

fail()
{
    echo "[FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_command()
{
    local command_name="$1"

    if command -v "$command_name" >/dev/null 2>&1; then
        pass "$command_name is available"
    else
        fail "$command_name is not available"
    fi
}

check_file()
{
    local file_path="$1"
    local description="$2"

    if [ -f "$file_path" ]; then
        pass "$description found"
    else
        fail "$description missing: $file_path"
    fi
}

check_directory()
{
    local directory_path="$1"
    local description="$2"

    if [ -d "$directory_path" ]; then
        pass "$description exists"
    else
        fail "$description missing: $directory_path"
    fi
}

check_writable_directory()
{
    local directory_path="$1"
    local description="$2"

    if [ ! -d "$directory_path" ]; then
        fail "$description missing: $directory_path"
        return
    fi

    if [ -w "$directory_path" ]; then
        pass "$description is writable"
    else
        fail "$description is not writable: $directory_path"
    fi
}

check_shell_syntax()
{
    local file_path="$1"
    local description="$2"

    if [ ! -f "$file_path" ]; then
        fail "$description missing: $file_path"
        return
    fi

    if bash -n "$file_path" >/dev/null 2>&1; then
        pass "$description syntax is valid"
    else
        fail "$description contains a syntax error"
    fi
}

check_script_access()
{
    local file_path="$1"
    local description="$2"

    if [ ! -f "$file_path" ]; then
        fail "$description is missing"
        return
    fi

    if [ ! -r "$file_path" ]; then
        fail "$description is not readable"
        return
    fi

    if [[ "$PROJECT_DIR" == /boot/* ]]; then
        pass "$description is readable and can be run with bash"
    elif [ -x "$file_path" ]; then
        pass "$description is executable"
    else
        warn "$description is readable but not executable"
    fi
}

print_header

############################################################
# Platform
############################################################

section "Platform"

if [ -f /etc/unraid-version ]; then
    pass "Unraid detected"

    UNRAID_VERSION=$(awk -F= '/^version=/{gsub(/"/,"",$2); print $2}' /etc/unraid-version)

    if [ -n "${UNRAID_VERSION:-}" ]; then
        echo "       Version: $UNRAID_VERSION"
    fi
else
    warn "Unraid was not positively detected"
fi

if [ "$(id -u)" -eq 0 ]; then
    pass "Running as root"
else
    warn "Not running as root"
fi

############################################################
# Required commands
############################################################

section "Required Commands"

check_command bash
check_command docker
check_command rsync
check_command find
check_command awk
check_command sed
check_command grep
check_command sort
check_command date
check_command du
check_command df

############################################################
# Project files
############################################################

section "Project Files"

check_file "$PROJECT_DIR/archive.sh" "Main archive controller"
check_file "$PROJECT_DIR/install.sh" "Installer"
check_file "$PROJECT_DIR/uninstall.sh" "Uninstaller"
check_file "$PROJECT_DIR/healthcheck.sh" "Health check utility"
check_file "$PROJECT_DIR/config.conf.example" "Example configuration"
check_file "$PROJECT_DIR/README.md" "README"
check_file "$PROJECT_DIR/CHANGELOG.md" "Changelog"
check_file "$PROJECT_DIR/LICENSE" "License"

check_directory "$MODULE_DIR" "Modules directory"

REQUIRED_MODULES=(
    "archive.sh"
    "checks.sh"
    "database_cleanup.sh"
    "logging.sh"
    "notifications.sh"
    "notify.sh"
    "transfer.sh"
    "utils.sh"
    "verify.sh"
)

for module in "${REQUIRED_MODULES[@]}"
do
    check_file "$MODULE_DIR/$module" "Module $module"
done

############################################################
# Shell syntax
############################################################

section "Shell Syntax"

check_shell_syntax "$PROJECT_DIR/archive.sh" "archive.sh"
check_shell_syntax "$PROJECT_DIR/install.sh" "install.sh"
check_shell_syntax "$PROJECT_DIR/uninstall.sh" "uninstall.sh"
check_shell_syntax "$PROJECT_DIR/healthcheck.sh" "healthcheck.sh"

for module in "${REQUIRED_MODULES[@]}"
do
    check_shell_syntax "$MODULE_DIR/$module" "$module"
done

############################################################
# Configuration
############################################################

section "Configuration"

if [ ! -f "$CONFIG_FILE" ]; then

    fail "config.conf is missing"

else

    pass "config.conf found"

    if bash -n "$CONFIG_FILE" >/dev/null 2>&1; then
        pass "config.conf syntax is valid"
    else
        fail "config.conf contains a syntax error"
    fi

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
            pass "$setting is configured"
        else
            fail "$setting is missing or empty"
        fi
    done

    if [[ "${START_THRESHOLD:-}" =~ ^[0-9]+$ ]] &&
       [[ "${STOP_THRESHOLD:-}" =~ ^[0-9]+$ ]]; then

        if [ "$START_THRESHOLD" -gt "$STOP_THRESHOLD" ]; then
            pass "Archive thresholds are logically ordered"
        else
            fail "START_THRESHOLD must be greater than STOP_THRESHOLD"
        fi

        if [ "$START_THRESHOLD" -ge 1 ] &&
           [ "$START_THRESHOLD" -le 100 ] &&
           [ "$STOP_THRESHOLD" -ge 0 ] &&
           [ "$STOP_THRESHOLD" -le 99 ]; then
            pass "Archive thresholds are within valid percentage ranges"
        else
            fail "Archive thresholds must be between 0 and 100"
        fi

    else
        fail "Archive thresholds must contain whole numbers"
    fi

    if [[ "${DB_BACKUP_KEEP:-}" =~ ^[0-9]+$ ]] &&
       [ "$DB_BACKUP_KEEP" -ge 1 ]; then
        pass "DB_BACKUP_KEEP is valid"
    else
        fail "DB_BACKUP_KEEP must be a positive whole number"
    fi

    if [[ "${KEEP_LOGS:-}" =~ ^[0-9]+$ ]] &&
       [ "$KEEP_LOGS" -ge 1 ]; then
        pass "KEEP_LOGS is valid"
    else
        fail "KEEP_LOGS must be a positive whole number"
    fi

    case "${TEST_MODE:-}" in
        true)
            warn "TEST_MODE is enabled"
            ;;
        false)
            pass "TEST_MODE is disabled"
            ;;
        *)
            fail "TEST_MODE must be true or false"
            ;;
    esac

fi

############################################################
# Frigate
############################################################

section "Frigate"

if [ -n "${CONTAINER:-}" ]; then

    if docker ps -a --format '{{.Names}}' |
       grep -Fxq "$CONTAINER"; then

        pass "Frigate container exists: $CONTAINER"

        CONTAINER_STATE=$(docker inspect \
            -f '{{.State.Status}}' "$CONTAINER" 2>/dev/null)

        if [ "$CONTAINER_STATE" = "running" ]; then
            pass "Frigate container is running"
        else
            fail "Frigate container is not running: $CONTAINER_STATE"
        fi

    else
        fail "Frigate container not found: $CONTAINER"
    fi

fi

if [ -n "${FRIGATE_DB:-}" ]; then

    if [ -f "$FRIGATE_DB" ]; then
        pass "Frigate database found"

        DB_SIZE=$(du -h "$FRIGATE_DB" | awk '{print $1}')
        echo "       Size: $DB_SIZE"
    else
        fail "Frigate database missing: $FRIGATE_DB"
    fi

fi

############################################################
# Storage
############################################################

section "Storage"

if [ -n "${SOURCE:-}" ]; then

    check_directory "$SOURCE" "Recording path"

    if [ -d "$SOURCE" ]; then

        SOURCE_USAGE=$(df -P "$SOURCE" |
            awk 'NR==2 {gsub("%","",$5); print $5}')

        SOURCE_FREE=$(df -hP "$SOURCE" |
            awk 'NR==2 {print $4}')

        pass "Recording path is accessible"
        echo "       Usage: ${SOURCE_USAGE}%"
        echo "       Free : $SOURCE_FREE"
    fi

fi

if [ -n "${ARCHIVE:-}" ]; then

    check_writable_directory "$ARCHIVE" "Archive path"

    if [ -d "$ARCHIVE" ]; then

        ARCHIVE_FREE=$(df -hP "$ARCHIVE" |
            awk 'NR==2 {print $4}')

        echo "       Free : $ARCHIVE_FREE"
    fi

fi

if [ -n "${LOG_DIR:-}" ]; then
    check_writable_directory "$LOG_DIR" "Log directory"
fi

if [ -d "$PROJECT_DIR/backups" ]; then
    check_writable_directory "$PROJECT_DIR/backups" "Project backup directory"
else
    warn "Project backup directory does not exist"
fi

############################################################
# Script access
############################################################

section "Script Access"

if [[ "$PROJECT_DIR" == /boot/* ]]; then
    pass "Project is stored on the Unraid FAT boot filesystem"
    echo "       Linux executable bits are not supported on /boot."
    echo "       Scripts should be launched with: bash script-name.sh"
fi

SCRIPT_FILES=(
    "$PROJECT_DIR/archive.sh"
    "$PROJECT_DIR/install.sh"
    "$PROJECT_DIR/uninstall.sh"
    "$PROJECT_DIR/healthcheck.sh"
)

for file_path in "${SCRIPT_FILES[@]}"
do
    check_script_access "$file_path" "$(basename "$file_path")"
done

for module in "${REQUIRED_MODULES[@]}"
do
    check_script_access "$MODULE_DIR/$module" "$module"
done

############################################################
# Runtime state
############################################################

section "Runtime State"

if [ -n "${LOCKFILE:-}" ]; then

    if [ -f "$LOCKFILE" ]; then

        LOCK_PID=$(awk -F= '/^PID=/{print $2}' "$LOCKFILE" 2>/dev/null)

        if [ -n "$LOCK_PID" ] &&
           kill -0 "$LOCK_PID" 2>/dev/null; then

            warn "Archive process appears to be running with PID $LOCK_PID"

        else

            warn "Stale lock file detected: $LOCKFILE"

        fi

    else

        pass "No archive lock is currently active"

    fi

fi

TEMP_FILES=$(find /tmp \
    -maxdepth 1 \
    -type f \
    -name 'frigate_cleanup_*.py' 2>/dev/null |
    wc -l)

if [ "$TEMP_FILES" -eq 0 ]; then
    pass "No stale cleanup scripts found in /tmp"
else
    warn "$TEMP_FILES stale cleanup script(s) found in /tmp"
fi

############################################################
# Git
############################################################

section "Git"

if command -v git >/dev/null 2>&1; then

    pass "Git is available"

    if git -C "$PROJECT_DIR" rev-parse \
       --is-inside-work-tree >/dev/null 2>&1; then

        pass "Project is inside a Git repository"

        CURRENT_BRANCH=$(git -C "$PROJECT_DIR" \
            branch --show-current 2>/dev/null)

        CURRENT_COMMIT=$(git -C "$PROJECT_DIR" \
            rev-parse --short HEAD 2>/dev/null)

        CURRENT_TAG=$(git -C "$PROJECT_DIR" \
            describe --tags --exact-match 2>/dev/null || true)

        echo "       Branch: ${CURRENT_BRANCH:-unknown}"
        echo "       Commit: ${CURRENT_COMMIT:-unknown}"

        if [ -n "$CURRENT_TAG" ]; then
            echo "       Tag   : $CURRENT_TAG"
        fi

        if [ -z "$(git -C "$PROJECT_DIR" status --porcelain)" ]; then
            pass "Git working tree is clean"
        else
            warn "Git working tree contains uncommitted changes"
        fi

    else
        warn "Project is not inside a Git repository"
    fi

else
    warn "Git is not available"
fi

############################################################
# Summary
############################################################

section "Summary"

echo "Passed  : $PASS_COUNT"
echo "Warnings: $WARN_COUNT"
echo "Failed  : $FAIL_COUNT"
echo

if [ "$FAIL_COUNT" -gt 0 ]; then

    echo "Overall Status: UNHEALTHY"
    echo
    exit 1

elif [ "$WARN_COUNT" -gt 0 ]; then

    echo "Overall Status: HEALTHY WITH WARNINGS"
    echo
    exit 0

else

    echo "Overall Status: HEALTHY"
    echo
    exit 0

fi
