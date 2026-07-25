#!/bin/bash

register_route "GET"  "/orders"      "get_orders"
register_route "GET"  "/orders/{id}" "get_order"
register_route "POST" "/orders"      "post_orders"

get_orders() {
    local result
    result=$(db_raw_query "
        SELECT o.id, u.username AS customer, p.name AS product,
               o.quantity, o.order_date
        FROM orders o
        JOIN users    u ON u.id = o.user_id
        JOIN products p ON p.id = o.product_id
        ORDER BY o.order_date DESC;
    ")
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

get_order() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(db_raw_query "
        SELECT o.id, u.username AS customer, p.name AS product,
               o.quantity, o.order_date
        FROM orders o
        JOIN users    u ON u.id = o.user_id
        JOIN products p ON p.id = o.product_id
        WHERE o.id = $id;
    ")
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

    db_insert "orders" "user_id, product_id, quantity, order_date" \
        "$user_id, $product_id, $quantity, datetime('now')"
    local id
    id=$(db_get_last_insert_id)
    http_response "201 Created" "application/json" \
        "$(db_select "orders" "id, user_id, product_id, quantity, order_date" "id = $id")"
}
