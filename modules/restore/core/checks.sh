#!/bin/bash

############################################################
#
# Frigate Archive
# Restore Checks Module
#
# Provides:
# - Configuration validation
# - Required command checks
# - Path and permission checks
# - Restore lock management
#
############################################################

############################################################
# Load and validate configuration
############################################################

load_restore_configuration()
{
    local config_file="$PROJECT_DIR/config.conf"

    restore_info "Loading restore configuration..."

    if [ ! -f "$config_file" ]; then
        restore_error "Configuration file not found:"
        restore_error "$config_file"
        return 1
    fi

    if ! bash -n "$config_file" >/dev/null 2>&1; then
        restore_error "Configuration file contains a syntax error:"
        restore_error "$config_file"
        return 1
    fi

    # shellcheck disable=SC1090
    source "$config_file"

    local required_settings=(
        SOURCE
        ARCHIVE
    )

    local setting

    for setting in "${required_settings[@]}"
    do
        if [ -z "${!setting:-}" ]; then
            restore_error "Required configuration setting is missing:"
            restore_error "$setting"
            return 1
        fi
    done

    restore_info "Recording path : $SOURCE"
    restore_info "Archive path   : $ARCHIVE"

    restore_success "Restore configuration loaded."

    return 0
}

############################################################
# Root check
############################################################

check_restore_root()
{
    if [ "$(id -u)" -ne 0 ]; then
        restore_error "Restore Wizard must be run as root."
        return 1
    fi

    restore_success "Running as root."

    return 0
}

############################################################
# Required command checks
############################################################

check_restore_commands()
{
    restore_info "Checking required commands..."

    local required_commands=(
        awk
        bash
        date
        df
        du
        find
        grep
        mkdir
        numfmt
        rsync
        sort
        tee
        touch
        tr
        wc
    )

    local command_name
    local missing=0

    for command_name in "${required_commands[@]}"
    do
        if command -v "$command_name" >/dev/null 2>&1; then
            restore_success "$command_name available"
        else
            restore_error "$command_name unavailable"
            missing=1
        fi
    done

    if [ "$missing" -ne 0 ]; then
        restore_error "One or more required commands are unavailable."
        return 1
    fi

    return 0
}

############################################################
# Archive path checks
############################################################

check_restore_archive_path()
{
    if [ ! -d "$ARCHIVE" ]; then
        restore_error "Archive path does not exist:"
        restore_error "$ARCHIVE"
        return 1
    fi

    if [ ! -r "$ARCHIVE" ]; then
        restore_error "Archive path is not readable:"
        restore_error "$ARCHIVE"
        return 1
    fi

    restore_success "Archive path is readable."

    return 0
}

############################################################
# Recording path checks
############################################################

check_restore_source_path()
{
    if [ ! -d "$SOURCE" ]; then
        restore_error "Recording path does not exist:"
        restore_error "$SOURCE"
        return 1
    fi

    if [ ! -w "$SOURCE" ]; then
        restore_error "Recording path is not writable:"
        restore_error "$SOURCE"
        return 1
    fi

    restore_success "Recording path is writable."

    return 0
}

############################################################
# Log directory check
############################################################

check_restore_log_directory()
{
    if ! mkdir -p "$RESTORE_LOG_DIR"; then
        restore_error "Unable to create restore log directory:"
        restore_error "$RESTORE_LOG_DIR"
        return 1
    fi

    if [ ! -w "$RESTORE_LOG_DIR" ]; then
        restore_error "Restore log directory is not writable:"
        restore_error "$RESTORE_LOG_DIR"
        return 1
    fi

    restore_success "Restore log directory is writable."

    return 0
}

############################################################
# Restore lock
############################################################

acquire_restore_lock()
{
    if [ -f "$RESTORE_LOCK" ]; then

        local existing_pid

        existing_pid=$(
            awk -F= \
                '/^PID=/{print $2}' \
                "$RESTORE_LOCK" \
                2>/dev/null ||
            true
        )

        if [ -n "$existing_pid" ] &&
           kill -0 "$existing_pid" 2>/dev/null; then

            restore_error "Another restore appears to be running."
            restore_error "PID: $existing_pid"

            return 1

        fi

        restore_warning "Removing stale restore lock:"
        restore_warning "$RESTORE_LOCK"

        rm -f "$RESTORE_LOCK"
    fi

    {
        echo "PID=$$"
        echo "STARTED=$(date --iso-8601=seconds)"
    } > "$RESTORE_LOCK"

    if [ $? -ne 0 ]; then
        restore_error "Unable to create restore lock:"
        restore_error "$RESTORE_LOCK"
        return 1
    fi

    LOCK_ACQUIRED=true

    restore_success "Restore lock acquired."

    return 0
}

############################################################
# Recording drive usage
############################################################

report_restore_storage()
{
    local source_usage
    local source_free
    local archive_free

    source_usage=$(
        df -P "$SOURCE" |
        awk 'NR==2 {print $5}'
    )

    source_free=$(
        df -hP "$SOURCE" |
        awk 'NR==2 {print $4}'
    )

    archive_free=$(
        df -hP "$ARCHIVE" |
        awk 'NR==2 {print $4}'
    )

    restore_info "Recording drive usage: $source_usage"
    restore_info "Recording drive free : $source_free"
    restore_info "Archive storage free : $archive_free"

    return 0
}

############################################################
# Main restore checks
############################################################

run_restore_checks()
{
    restore_info "Running restore system checks..."

    if ! check_restore_root; then
        return 1
    fi

    if ! load_restore_configuration; then
        return 1
    fi

    if ! check_restore_commands; then
        return 1
    fi

    if ! check_restore_archive_path; then
        return 1
    fi

    if ! check_restore_source_path; then
        return 1
    fi

    if ! check_restore_log_directory; then
        return 1
    fi

    if ! acquire_restore_lock; then
        return 1
    fi

    report_restore_storage

    restore_success "All restore system checks passed."

    return 0
}
