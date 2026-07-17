#!/bin/bash

############################################################
#
# Frigate Archive
# Restore Menu Module
#
# Provides:
# - Archive date discovery
# - Archive statistics table
# - Interactive date selection
# - Direct date argument validation
#
############################################################

############################################################
# Discover archived dates
############################################################

find_restore_dates()
{
    mapfile -t AVAILABLE_DATES < <(
        find "$ARCHIVE" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -printf '%f\n' |
        grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' |
        sort
    )

    if [ "${#AVAILABLE_DATES[@]}" -eq 0 ]; then
        restore_error "No archived date folders were found."
        return 1
    fi

    return 0
}

############################################################
# Show archive statistics table
############################################################

show_restore_date_menu()
{
    echo
    restore_info "Scanning archived dates and calculating statistics..."
    echo
    echo "Available archived dates"
    echo "-------------------------------------------------------------------------------"

    printf " %-4s %-12s %12s %14s %14s\n" \
        "No." \
        "Date" \
        "Folders" \
        "Files" \
        "Size"

    echo "-------------------------------------------------------------------------------"

    local index
    local menu_day
    local menu_path
    local folder_count
    local file_count
    local menu_bytes
    local menu_size

    for index in "${!AVAILABLE_DATES[@]}"
    do
        menu_day="${AVAILABLE_DATES[$index]}"
        menu_path="$ARCHIVE/$menu_day"

        folder_count=$(
            find "$menu_path" \
                -mindepth 1 \
                -type d \
                2>/dev/null |
            wc -l
        )

        file_count=$(
            find "$menu_path" \
                -type f \
                2>/dev/null |
            wc -l
        )

        menu_bytes=$(
            du -sb "$menu_path" \
                2>/dev/null |
            awk '{print $1}'
        )

        if ! [[ "$menu_bytes" =~ ^[0-9]+$ ]]; then
            menu_size="unknown"
        else
            menu_size=$(
                restore_human_bytes "$menu_bytes"
            )
        fi

        printf " %3d) %-12s %12d %14d %14s\n" \
            "$((index + 1))" \
            "$menu_day" \
            "$folder_count" \
            "$file_count" \
            "$menu_size"
    done

    echo "-------------------------------------------------------------------------------"
    echo
    echo "   q) Cancel"
    echo
}

############################################################
# Validate direct date argument
############################################################

validate_restore_date_argument()
{
    local requested_day="$1"

    if [[ ! "$requested_day" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        restore_error "Invalid date format: $requested_day"
        restore_error "Required format: YYYY-MM-DD"
        return 1
    fi

    if [ ! -d "$ARCHIVE/$requested_day" ]; then
        restore_error "Archived date was not found:"
        restore_error "$ARCHIVE/$requested_day"
        return 1
    fi

    return 0
}

############################################################
# Interactive date selection
############################################################

select_restore_date_interactive()
{
    local selection

    show_restore_date_menu

    read -rp "Select a date to restore: " selection

    case "$selection" in
        q|Q)
            restore_info "Restore cancelled."
            return 2
            ;;
    esac

    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        restore_error "Selection must be a number."
        return 1
    fi

    if [ "$selection" -lt 1 ] ||
       [ "$selection" -gt "${#AVAILABLE_DATES[@]}" ]; then

        restore_error "Selection is outside the available range."
        return 1

    fi

    SELECTED_DAY="${AVAILABLE_DATES[$((selection - 1))]}"

    return 0
}

############################################################
# Main date-selection entry point
############################################################

select_restore_date()
{
    local requested_day="${1:-}"
    local status

    if ! find_restore_dates; then
        return 1
    fi

    if [ -n "$requested_day" ]; then

        if ! validate_restore_date_argument "$requested_day"; then
            return 1
        fi

        SELECTED_DAY="$requested_day"

    else

        select_restore_date_interactive
        status=$?

        if [ "$status" -eq 2 ]; then
            return 2
        fi

        if [ "$status" -ne 0 ]; then
            return 1
        fi

    fi

    ARCHIVE_DAY="$ARCHIVE/$SELECTED_DAY"
    RESTORE_DAY="$SOURCE/$SELECTED_DAY"

    restore_success "Restore date selected: $SELECTED_DAY"

    return 0
}
