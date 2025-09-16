#!/bin/bash

validate_json() {
    local json_string="$1"
    echo "$json_string" | jq empty 2>/dev/null
    return $?
}

validate_required_fields() {
    local json_string="$1"
    shift
    local required_fields=("$@")
    
    for field in "${required_fields[@]}"; do
        local value=$(echo "$json_string" | jq -r ".$field // empty")
        if [ -z "$value" ] || [ "$value" = "null" ]; then
            echo "Missing required field: $field"
            return 1
        fi
    done
    return 0
}

validate_email() {
    local email="$1"
    local email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    [[ "$email" =~ $email_regex ]]
}

validate_integer() {
    local value="$1"
    [[ "$value" =~ ^[0-9]+$ ]]
}

sanitize_input() {
    local input="$1"
    printf '%s' "$input" | tr -d '\000-\031\177'
}

validate_path_param() {
    local param="$1"
    if ! validate_integer "$param"; then
        http_response "400 Bad Request" "application/json" '{"error":"Invalid ID parameter"}'
        return 1
    fi
    return 0
}