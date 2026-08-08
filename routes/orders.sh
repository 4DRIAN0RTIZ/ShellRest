#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../shellrest/models/orders.sh"

register_route "GET"  "/orders"      "get_orders"
register_route "GET"  "/orders/{id}" "get_order"
register_route "POST" "/orders"      "post_orders"

get_orders() {
    local result
    result=$(orders_find_all)
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

get_order() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(orders_find "$id")
    if [ -z "$result" ] || [ "$result" = "[]" ]; then
        http_response "404 Not Found" "application/json" "$(json_error "Order not found")"
    else
        http_response "200 OK" "application/json" "$result"
    fi
}

post_orders() {
    local body="$1"

    if ! validate_required_fields "$body" "user_id" "product_id" "quantity"; then
        http_response "400 Bad Request" "application/json" \
            "$(json_error "user_id, product_id and quantity are required")"
        return
    fi

    local user_id product_id quantity
    user_id=$(get_json_field "$body" "user_id")
    product_id=$(get_json_field "$body" "product_id")
    quantity=$(get_json_field "$body" "quantity")

    local id
    id=$(orders_create "$user_id" "$product_id" "$quantity")
    http_response "201 Created" "application/json" \
        "$(orders_find_plain "$id")"
}
