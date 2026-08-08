#!/bin/bash

orders_find_all() {
    db_raw_query "
        SELECT o.id, u.username AS customer, p.name AS product,
               o.quantity, o.order_date
        FROM orders o
        JOIN users    u ON u.id = o.user_id
        JOIN products p ON p.id = o.product_id
        ORDER BY o.order_date DESC;
    "
}

orders_find() {
    local id="$1"
    db_raw_query "
        SELECT o.id, u.username AS customer, p.name AS product,
               o.quantity, o.order_date
        FROM orders o
        JOIN users    u ON u.id = o.user_id
        JOIN products p ON p.id = o.product_id
        WHERE o.id = $id;
    "
}

orders_find_plain() {
    local id="$1"
    db_select "orders" "id, user_id, product_id, quantity, order_date" "id = $id"
}

orders_create() {
    local user_id="$1" product_id="$2" quantity="$3"
    db_insert "orders" "user_id, product_id, quantity, order_date" \
        "$user_id, $product_id, $quantity, datetime('now')"
}
