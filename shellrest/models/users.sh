#!/bin/bash

users_find_all() {
    db_select "users" "id, username, email, is_active"
}

users_find() {
    local id="$1"
    db_select "users" "id, username, email, is_active" "id = $id"
}

users_create() {
    local username="$1" email="$2"
    db_insert "users" "username, email" \
        "$(safe_sql_string "$username"), $(safe_sql_string "$email")"
}

users_update() {
    local id="$1" username="$2" email="$3"
    db_update "users" \
        "username = $(safe_sql_string "$username"), email = $(safe_sql_string "$email")" \
        "id = $id"
}

users_delete() {
    local id="$1"
    db_delete "users" "id = $id"
}
