#!/bin/bash

declare -a middleware_stack=()

add_middleware() {
    local middleware_function="$1"
    middleware_stack+=("$middleware_function")
}

run_middleware() {
    local request_method="$1"
    local request_path="$2"
    local request_body="$3"

    for middleware in "${middleware_stack[@]}"; do
        if declare -f "$middleware" >/dev/null 2>&1; then
            "$middleware" "$request_method" "$request_path" "$request_body"
            if [ $? -ne 0 ]; then
                return 1
            fi
        fi
    done
    return 0
}

cors_middleware() {
    if [ "$1" = "OPTIONS" ]; then
        echo -e "HTTP/1.1 204 No Content\r"
        echo -e "Access-Control-Allow-Origin: *\r"
        echo -e "Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS\r"
        echo -e "Access-Control-Allow-Headers: Content-Type, Authorization\r"
        echo -e "Content-Length: 0\r"
        echo -e "\r"
        return 1
    fi
    return 0
}

logging_middleware() {
    local method="$1"
    local path="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $method $path" >> "${LOG_FILE:-access.log}"
    return 0
}

auth_middleware() {
    local method="$1"
    local path="$2"
    local auth_header
    auth_header=$(echo -e "$request_headers" | grep -i "authorization" | awk -F': ' '{print $2}' | tr -d '\r')

    if [[ "$path" == "/protected"* ]] && [ -z "$auth_header" ]; then
        http_response "401 Unauthorized" "application/json" '{"error":"Authentication required"}'
        return 1
    fi
    return 0
}