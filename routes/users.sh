#!/bin/bash

source "shellrest/http.sh"
source "shellrest/database.sh"
source "shellrest/utils.sh"

register_route "GET"    "/users"      "get_users"
register_route "POST"   "/users"      "post_users"
register_route "GET"    "/users/{id}" "get_user"
register_route "PUT"    "/users/{id}" "put_user"
register_route "DELETE" "/users/{id}" "delete_user"

get_users() {
    local result
    result=$(db_select "users" "id, username, email, is_active")
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

get_user() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(db_select "users" "id, username, email, is_active" "id = $id")
    if [ -z "$result" ] || [ "$result" = "[]" ]; then
        http_response "404 Not Found" "application/json" "$(json_error "User not found")"
    else
        http_response "200 OK" "application/json" "$result"
    fi
}

post_users() {
    local body="$1"

    if ! validate_required_fields "$body" "username"; then
        http_response "400 Bad Request" "application/json" "$(json_error "username is required")"
        return
    fi

    local username email
    username=$(get_json_field "$body" "username")
    email=$(get_json_field "$body" "email")

    if [ -n "$email" ] && ! validate_email "$email"; then
        http_response "400 Bad Request" "application/json" "$(json_error "invalid email format")"
        return
    fi

    local id
    id=$(db_insert "users" "username, email" \
        "$(safe_sql_string "$username"), $(safe_sql_string "$email")")
    http_response "201 Created" "application/json" \
        "$(db_select "users" "id, username, email, is_active" "id = $id")"
}

put_user() {
    local id="$1" body="$2"
    validate_path_param "$id" || return

    if ! validate_required_fields "$body" "username"; then
        http_response "400 Bad Request" "application/json" "$(json_error "username is required")"
        return
    fi

    local username email
    username=$(get_json_field "$body" "username")
    email=$(get_json_field "$body" "email")

    if [ -n "$email" ] && ! validate_email "$email"; then
        http_response "400 Bad Request" "application/json" "$(json_error "invalid email format")"
        return
    fi

    db_update "users" \
        "username = $(safe_sql_string "$username"), email = $(safe_sql_string "$email")" \
        "id = $id"

    local changes
    changes=$(db_get_changes)
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "200 OK" "application/json" \
            "$(db_select "users" "id, username, email, is_active" "id = $id")"
    else
        http_response "404 Not Found" "application/json" "$(json_error "User not found")"
    fi
}

delete_user() {
    local id="$1"
    validate_path_param "$id" || return
    db_delete "users" "id = $id"
    local changes
    changes=$(db_get_changes)
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "204 No Content" "application/json" ""
    else
        http_response "404 Not Found" "application/json" "$(json_error "User not found")"
    fi
}
