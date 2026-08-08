#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../shellrest/models/users.sh"

register_route "GET"    "/users"      "get_users"
register_route "POST"   "/users"      "post_users"
register_route "GET"    "/users/{id}" "get_user"
register_route "PUT"    "/users/{id}" "put_user"
register_route "DELETE" "/users/{id}" "delete_user"

# Views
register_route "GET" "/users/view" "get_users_view"

get_users_view() {
    local json
    json=$(users_find_all)
    [ -z "$json" ] && json="[]"

    local count
    count=$(printf '%s' "$json" | jq 'length')

    local -a row_htmls=()
    local i id username email active_label
    for (( i=0; i<count; i++ )); do
        id=$(printf '%s' "$json" | jq -r ".[$i].id")
        username=$(printf '%s' "$json" | jq -r ".[$i].username")
        email=$(printf '%s' "$json" | jq -r ".[$i].email // \"\"")
        if [ "$(printf '%s' "$json" | jq -r ".[$i].is_active")" = "1" ]; then
            active_label="Active"
        else
            active_label="Inactive"
        fi
        row_htmls+=("$(render_partial "user_row.html" \
            "id" "$id" "username" "$username" "email" "$email" "status" "$active_label")")
    done

    local body
    body=$(render_view "users_list.html" "users" "row_htmls" "title" "User List" "count" "$count")
    http_response "200 OK" "text/html" "$body"
}

get_users() {
    local result
    result=$(users_find_all)
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

get_user() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(users_find "$id")
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
    id=$(users_create "$username" "$email")
    http_response "201 Created" "application/json" \
        "$(users_find "$id")"
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

    local changes
    changes=$(users_update "$id" "$username" "$email")
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "200 OK" "application/json" \
            "$(users_find "$id")"
    else
        http_response "404 Not Found" "application/json" "$(json_error "User not found")"
    fi
}

delete_user() {
    local id="$1"
    validate_path_param "$id" || return
    local changes
    changes=$(users_delete "$id")
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "204 No Content" "application/json" ""
    else
        http_response "404 Not Found" "application/json" "$(json_error "User not found")"
    fi
}
