#!/bin/bash

_FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_PROJECT_ROOT="$(dirname "$_FRAMEWORK_DIR")"

DEFAULT_PORT=8082
DEFAULT_HOST="localhost"
DEFAULT_DB_FILE="sqlite_data.db"
DEFAULT_LOG_FILE="access.log"
DEFAULT_DEBUG=false
DEFAULT_VIEWS_DIR="views"

load_config() {
    local config_file="${CONFIG_FILE:-${_PROJECT_ROOT}/.env}"
    if [ -f "$config_file" ]; then
        source "$config_file"
    fi

    export API_PORT="${API_PORT:-$DEFAULT_PORT}"
    export API_HOST="${API_HOST:-$DEFAULT_HOST}"
    export DB_FILE="${DB_FILE:-${_PROJECT_ROOT}/${DEFAULT_DB_FILE}}"
    export LOG_FILE="${LOG_FILE:-${_PROJECT_ROOT}/${DEFAULT_LOG_FILE}}"
    export DEBUG="${DEBUG:-$DEFAULT_DEBUG}"
    export VIEWS_DIR="${VIEWS_DIR:-${_PROJECT_ROOT}/${DEFAULT_VIEWS_DIR}}"
}

get_config() {
    local key="$1"
    case "$key" in
        "port")      printf '%s' "$API_PORT"  ;;
        "host")      printf '%s' "$API_HOST"  ;;
        "db_file")   printf '%s' "$DB_FILE"   ;;
        "log_file")  printf '%s' "$LOG_FILE"  ;;
        "debug")     printf '%s' "$DEBUG"     ;;
        "views_dir") printf '%s' "$VIEWS_DIR" ;;
        *)           return 1                 ;;
    esac
}

debug_log() {
    if [ "$DEBUG" = "true" ]; then
        printf '[DEBUG] %s\n' "$*" >&2
    fi
}
