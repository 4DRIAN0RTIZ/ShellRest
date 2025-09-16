#!/bin/bash

http_response() {
    local status="$1"
    local content_type="$2"
    local body="$3"
    local content_length
    content_length=$(printf '%s' "$body" | wc -c)

    printf 'HTTP/1.1 %s\r\n'                              "$status"
    printf 'Content-Type: %s\r\n'                          "$content_type"
    printf 'Content-Length: %s\r\n'                        "$content_length"
    printf 'Access-Control-Allow-Origin: %s\r\n'           "${CORS_ORIGIN:-*}"
    printf 'Access-Control-Allow-Methods: %s\r\n'          "${CORS_METHODS:-GET, POST, PUT, DELETE, OPTIONS}"
    printf 'Access-Control-Allow-Headers: %s\r\n'          "${CORS_HEADERS:-Content-Type, Authorization}"
    printf '\r\n'
    printf '%s' "$body"
}

parse_query_string() {
    local query_string="$1"
    while IFS='=' read -r key value; do
        [[ -z "$key" ]] && continue
        key=$(printf '%b' "${key//%/\\x}")
        value=$(printf '%b' "${value//%/\\x}")
        export "QUERY_${key}"="${value}"
    done < <(printf '%s' "$query_string" | tr '&' '\n')
}

get_header() {
    local header_name="$1"
    while IFS=': ' read -r name value; do
        if [[ "${name,,}" == "${header_name,,}" ]]; then
            printf '%s' "${value%$'\r'}"
            return 0
        fi
    done <<< "$request_headers"
    return 1
}
