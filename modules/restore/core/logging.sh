#!/bin/bash

############################################################
#
# Frigate Archive
# Restore Logging and Runtime Module
#
# Provides:
# - Version loading
# - Timestamped output
# - Human-readable byte formatting
# - Restore log creation
# - Lock cleanup
# - Signal handling
#
############################################################

RESTORE_LOCK="${RESTORE_LOCK:-/tmp/frigate_archive_restore.lock}"
RESTORE_LOG_DIR="${RESTORE_LOG_DIR:-$PROJECT_DIR/logs}"

LOCK_ACQUIRED=false
RESTORE_SUCCESS=false
RESTORE_LOG=""

############################################################
# Load project version
############################################################

load_restore_version()
{
    local version_file="$PROJECT_DIR/VERSION"

    if [ -f "$version_file" ]; then

        VERSION="$(tr -d '[:space:]' < "$version_file")"

        if [ -z "$VERSION" ]; then
            VERSION="unknown"
        fi

    else

        VERSION="unknown"

    fi
}

############################################################
# Output helpers
############################################################

restore_timestamp()
{
    date '+%Y-%m-%d %H:%M:%S'
}

restore_info()
{
    echo "$(restore_timestamp) [INFO] $*"
}

restore_success()
{
    echo "$(restore_timestamp) [SUCCESS] $*"
}

restore_warning()
{
    echo "$(restore_timestamp) [WARNING] $*"
}

restore_error()
{
    echo "$(restore_timestamp) [ERROR] $*" >&2
}

restore_header()
{
    echo
    echo "============================================================"
    echo " Frigate Archive Restore Wizard"
    echo " Version $VERSION"
    echo "============================================================"
    echo
}

############################################################
# Human-readable byte formatting
############################################################

restore_human_bytes()
{
    local bytes="$1"

    if command -v numfmt >/dev/null 2>&1; then

        numfmt \
            --to=iec-i \
            --suffix=B \
            "$bytes" \
            2>/dev/null ||
        echo "${bytes} bytes"

    else

        echo "${bytes} bytes"

    fi
}

############################################################
# Restore log
############################################################

create_restore_log()
{
    local selected_day="$1"

    if ! mkdir -p "$RESTORE_LOG_DIR"; then
        restore_error "Unable to create restore log directory:"
        restore_error "$RESTORE_LOG_DIR"
        return 1
    fi

    RESTORE_LOG="$RESTORE_LOG_DIR/restore_${selected_day}_$(date +%F_%H%M%S).log"

    if ! touch "$RESTORE_LOG"; then
        restore_error "Unable to create restore log:"
        restore_error "$RESTORE_LOG"
        return 1
    fi

    restore_info "Restore log:"
    restore_info "$RESTORE_LOG"

    {
        echo "============================================================"
        echo "Frigate Archive Restore Wizard"
        echo "Version: $VERSION"
        echo "Started: $(date --iso-8601=seconds)"
        echo "Restore date: $selected_day"
        echo "============================================================"
    } >> "$RESTORE_LOG"

    return 0
}

restore_log_message()
{
    local level="$1"

    shift

    local message="$*"
    local line

    line="$(restore_timestamp) [$level] $message"

    echo "$line"

    if [ -n "$RESTORE_LOG" ]; then
        echo "$line" >> "$RESTORE_LOG"
    fi
}

############################################################
# Runtime cleanup
############################################################

restore_runtime_cleanup()
{
    local exit_status=$?

    if [ "$LOCK_ACQUIRED" = true ]; then

        rm -f "$RESTORE_LOCK"

        restore_success "Restore lock released."

    fi

    if [ "$RESTORE_SUCCESS" != true ] &&
       [ "$exit_status" -ne 0 ]; then

        restore_error "Restore did not complete successfully."

    fi
}

restore_signal_handler()
{
    restore_error "Restore interrupted."

    exit 130
}

install_restore_traps()
{
    trap restore_runtime_cleanup EXIT
    trap restore_signal_handler INT TERM HUP
}
