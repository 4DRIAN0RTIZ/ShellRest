#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/validation.sh"

# JSON field extraction

get_json_field() {
    local body="$1"
    local field="$2"
    printf '%s' "$body" | jq -r ".$field // empty"
}

get_required_field() {
    local body="$1"
    local field="$2"
    local value
    value=$(printf '%s' "$body" | jq -r ".$field // empty")
    [ -z "$value" ] && return 1
    printf '%s' "$value"
}

# Core DB helpers

db_query() {
    local query="$1"
    local format="${2:-table}"
    execute_query "$query" "$format"
}

db_query_json() {
    local query="$1"
    execute_query "$query" json
}

db_raw_query() {
    local query="$1"
    local format="${2:-json}"
    execute_query "$query" "$format"
}

db_insert() {
    local table="$1"
    local fields="$2"
    local values="$3"
    execute_query "INSERT INTO $table ($fields) VALUES ($values);"
}

db_update() {
    local table="$1"
    local set_clause="$2"
    local where_clause="$3"
    execute_query "UPDATE $table SET $set_clause WHERE $where_clause;"
}

db_delete() {
    local table="$1"
    local where_clause="$2"
    execute_query "DELETE FROM $table WHERE $where_clause;"
}

db_select() {
    local table="$1"
    local fields="${2:-*}"
    local where_clause="$3"
    local format="${4:-json}"
    local query="SELECT $fields FROM $table"
    [ -n "$where_clause" ] && query="$query WHERE $where_clause"
    execute_query "$query" "$format"
}

db_count() {
    local table="$1"
    local where_clause="$2"
    local query="SELECT COUNT(*) FROM $table"
    [ -n "$where_clause" ] && query="$query WHERE $where_clause"
    execute_query "$query"
}

db_exists() {
    local table="$1"
    local where_clause="$2"
    local count
    count=$(db_count "$table" "$where_clause")
    [ "${count:-0}" -gt 0 ]
}

db_get_last_insert_id() {
    execute_query "SELECT last_insert_rowid();"
}

db_get_changes() {
    execute_query "SELECT changes();"
}

safe_sql_string() {
    printf "'%s'" "$(escape_sql "$1")"
}

# JOIN builders

db_join() {
    local select_clause="$1"
    local from_table="$2"
    local join_clause="$3"
    local where_clause="$4"
    local order_clause="$5"
    local format="${6:-json}"
    local query="SELECT $select_clause FROM $from_table $join_clause"
    [ -n "$where_clause" ] && query="$query WHERE $where_clause"
    [ -n "$order_clause" ] && query="$query ORDER BY $order_clause"
    execute_query "$query" "$format"
}

db_inner_join() {
    local select_clause="$1" table1="$2" table2="$3"
    local on_condition="$4" where_clause="$5" order_clause="$6"
    local format="${7:-json}"
    db_join "$select_clause" "$table1" "INNER JOIN $table2 ON $on_condition" \
            "$where_clause" "$order_clause" "$format"
}

db_left_join() {
    local select_clause="$1" table1="$2" table2="$3"
    local on_condition="$4" where_clause="$5" order_clause="$6"
    local format="${7:-json}"
    db_join "$select_clause" "$table1" "LEFT JOIN $table2 ON $on_condition" \
            "$where_clause" "$order_clause" "$format"
}

db_multi_join() {
    local select_clause="$1" from_table="$2" joins="$3"
    local where_clause="$4" group_by="$5" having="$6"
    local order_clause="$7" limit_clause="$8"
    local format="${9:-json}"
    local query="SELECT $select_clause FROM $from_table $joins"
    [ -n "$where_clause"  ] && query="$query WHERE $where_clause"
    [ -n "$group_by"      ] && query="$query GROUP BY $group_by"
    [ -n "$having"        ] && query="$query HAVING $having"
    [ -n "$order_clause"  ] && query="$query ORDER BY $order_clause"
    [ -n "$limit_clause"  ] && query="$query LIMIT $limit_clause"
    execute_query "$query" "$format"
}

db_aggregate() {
    local select_clause="$1" from_clause="$2"
    local where_clause="$3" group_by="$4" having="$5"
    local format="${6:-json}"
    local query="SELECT $select_clause FROM $from_clause"
    [ -n "$where_clause" ] && query="$query WHERE $where_clause"
    [ -n "$group_by"     ] && query="$query GROUP BY $group_by"
    [ -n "$having"       ] && query="$query HAVING $having"
    execute_query "$query" "$format"
}

# Response helpers

json_error() {
    printf '{"error":"%s"}' "$1"
}

json_success() {
    printf '{"message":"%s"}' "$1"
}
