#!/bin/bash

DB_FILE="${DB_FILE:-sqlite_data.db}"

init_database() {
    sqlite3 "${DB_FILE}" "SELECT 1;" > /dev/null 2>&1 || {
        printf 'Error: cannot initialize database at %s\n' "${DB_FILE}" >&2
        return 1
    }
}

execute_query() {
    local query="$1"
    local format="${2:-table}"
    local result exit_code

    case "$format" in
        json) result=$(sqlite3 "${DB_FILE}" -json "$query" 2>&1) ;;
        csv)  result=$(sqlite3 "${DB_FILE}" -csv  "$query" 2>&1) ;;
        *)    result=$(sqlite3 "${DB_FILE}"        "$query" 2>&1) ;;
    esac
    exit_code=$?

    if [ $exit_code -ne 0 ]; then
        printf 'Database error: %s\n' "$result" >&2
        return $exit_code
    fi

    printf '%s' "$result"
}

escape_sql() {
    local input="$1"
    printf '%s' "${input//\'/\'\'}"
}
