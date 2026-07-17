#!/bin/bash

############################################
# Frigate Archive V2
# Database Cleanup Module
############################################


cleanup_database()
{

    local DAY="$1"
    local START_TS
    local END_TS
    local BACKUP
    local SIZE_BEFORE
    local SIZE_AFTER
    local TMP_SCRIPT
    local OUTPUT
    local STATUS
    local BACKUP_DIR
    local BACKUP_PATTERN
    local BACKUP_LIMIT
    local BACKUP_COUNT
    local INDEX


    ############################################
    # Validate cleanup day
    ############################################

    if [ -z "$DAY" ]; then

        error "No cleanup day supplied."

        return 1

    fi


    info "Starting Frigate database cleanup."
    info "Cleanup target:"
    info "$DAY"


    ############################################
    # Convert day to Unix timestamps
    ############################################

    START_TS=$(date -d "$DAY 00:00:00" +%s)
    END_TS=$(date -d "$DAY 23:59:59" +%s)


    if [ -z "$START_TS" ] || [ -z "$END_TS" ]; then

        error "Unable to calculate database cleanup timestamps."

        return 1

    fi


    info "Timestamp range:"
    info "$START_TS - $END_TS"


    ############################################
    # Validate database
    ############################################

    if [ ! -f "$FRIGATE_DB" ]; then

        error "Frigate database not found:"
        error "$FRIGATE_DB"

        return 1

    fi


    ############################################
    # Create database backup
    ############################################

    BACKUP="${FRIGATE_DB}.backup.$(date +%F_%H%M%S)"


    if ! cp -p "$FRIGATE_DB" "$BACKUP"; then

        error "Database backup failed."

        return 1

    fi


    success "Database backup created:"
    info "$BACKUP"


    ############################################
    # Prune old database backups
    ############################################

    BACKUP_DIR=$(dirname "$FRIGATE_DB")
    BACKUP_PATTERN="$(basename "$FRIGATE_DB").backup.*"
    BACKUP_LIMIT="${DB_BACKUP_KEEP:-7}"


    if ! [[ "$BACKUP_LIMIT" =~ ^[0-9]+$ ]] || [ "$BACKUP_LIMIT" -lt 1 ]; then

        warning "Invalid DB_BACKUP_KEEP value: $BACKUP_LIMIT"
        warning "Using default value of 7."

        BACKUP_LIMIT=7

    fi


    info "Checking database backup retention..."
    info "Backups to keep: $BACKUP_LIMIT"


    mapfile -t BACKUP_FILES < <(
        find "$BACKUP_DIR" \
            -maxdepth 1 \
            -type f \
            -name "$BACKUP_PATTERN" \
            -printf '%T@ %p\n' 2>/dev/null |
        sort -rn |
        cut -d' ' -f2-
    )


    BACKUP_COUNT=${#BACKUP_FILES[@]}


    info "Database backups found: $BACKUP_COUNT"


    if [ "$BACKUP_COUNT" -gt "$BACKUP_LIMIT" ]; then

        for ((INDEX=BACKUP_LIMIT; INDEX<BACKUP_COUNT; INDEX++))
        do

            info "Removing old database backup:"
            info "${BACKUP_FILES[$INDEX]}"


            if rm -f -- "${BACKUP_FILES[$INDEX]}"; then

                success "Old database backup removed."

            else

                warning "Unable to remove old database backup:"
                warning "${BACKUP_FILES[$INDEX]}"

            fi

        done

    else

        info "No old database backups need removing."

    fi


    success "Database backup retention complete."


    ############################################
    # Record database size before cleanup
    ############################################

    SIZE_BEFORE=$(du -sh "$FRIGATE_DB" | awk '{print $1}')


    info "Database size before cleanup: $SIZE_BEFORE"


    ############################################
    # Create temporary Python cleanup script
    ############################################

    TMP_SCRIPT="/tmp/frigate_cleanup_$$.py"


    cat > "$TMP_SCRIPT" <<'PY'
import sqlite3
import sys


DB_PATH = "/config/frigate.db"


def main() -> int:
    start = int(sys.argv[1])
    end = int(sys.argv[2])

    print("=== PYTHON SCRIPT STARTED ===")

    conn = sqlite3.connect(DB_PATH, timeout=60)
    cursor = conn.cursor()

    tables = [
        ("recordings", "start_time"),
        ("timeline", "timestamp"),
        ("reviewsegment", "start_time"),
        ("previews", "start_time"),
    ]

    try:
        integrity = cursor.execute("PRAGMA integrity_check").fetchone()[0]

        print(f"Database integrity: {integrity}")

        if integrity != "ok":
            raise RuntimeError(
                f"Database integrity check failed: {integrity}"
            )

        cursor.execute("BEGIN")

        for table, column in tables:
            cursor.execute(
                f"""
                SELECT COUNT(*)
                FROM {table}
                WHERE {column} >= ?
                  AND {column} <= ?
                """,
                (start, end),
            )

            matching = cursor.fetchone()[0]

            print()
            print(table)
            print("Matching :", matching)

            cursor.execute(
                f"""
                DELETE FROM {table}
                WHERE {column} >= ?
                  AND {column} <= ?
                """,
                (start, end),
            )

            print("Deleted  :", cursor.rowcount)

        conn.commit()

        print()
        print("Commit successful")

        cursor.execute("VACUUM")

        print("VACUUM complete")

        print()
        print("Verification")

        verification_failed = False

        for table, column in tables:
            cursor.execute(
                f"""
                SELECT COUNT(*)
                FROM {table}
                WHERE {column} >= ?
                  AND {column} <= ?
                """,
                (start, end),
            )

            remaining = cursor.fetchone()[0]

            if remaining == 0:
                print(f"{table:<15} PASS ({remaining} remaining)")
            else:
                verification_failed = True
                print(f"{table:<15} FAIL ({remaining} remaining)")

        if verification_failed:
            raise RuntimeError("Database cleanup verification failed")

        return 0

    except Exception as exc:
        conn.rollback()

        print()
        print("ERROR")
        print(repr(exc))

        return 1

    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())
PY


    if [ ! -s "$TMP_SCRIPT" ]; then

        error "Unable to create temporary database cleanup script."

        rm -f "$TMP_SCRIPT"

        return 1

    fi


    ############################################
    # Execute cleanup using Python container
    ############################################

    info "Launching Python cleanup container..."


    OUTPUT=$(
        docker run --rm \
            -v "$(dirname "$FRIGATE_DB"):/config" \
            -v "$TMP_SCRIPT:/cleanup.py:ro" \
            python:3.11-slim \
            python3 /cleanup.py "$START_TS" "$END_TS" 2>&1
    )

    STATUS=$?


    rm -f "$TMP_SCRIPT"


    while IFS= read -r LINE
    do

        info "$LINE"

    done <<< "$OUTPUT"


    if [ "$STATUS" -ne 0 ]; then

        error "Database cleanup failed."

        return 1

    fi


    ############################################
    # Report database size
    ############################################

    SIZE_AFTER=$(du -sh "$FRIGATE_DB" | awk '{print $1}')


    info "Database size:"
    info "Before : $SIZE_BEFORE"
    info "After  : $SIZE_AFTER"


    success "Database cleanup complete."


    return 0

}
