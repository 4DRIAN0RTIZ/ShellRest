#!/bin/bash

# Migration: orders
# Created: Mon Sep 15 10:36:49 PM CST 2025

source "$(dirname "$0")/../framework/migration.sh"

up() {
    local columns
    columns="$(id_column),
    $(integer_column "user_id" false),
    $(integer_column "product_id" false),
    $(integer_column "quantity" false),
    $(datetime_column "order_date" "now" false)"

    local constraints
    constraints="$(foreign_key "user_id" "users" "id"),
    $(foreign_key "product_id" "products" "id")"

    create_table "orders" "$columns" "$constraints"
}

down() {
    drop_table "orders"
}

if   [ "$1" = "up"   ]; then up
elif [ "$1" = "down" ]; then down
else echo "Usage: $0 {up|down}"; exit 1
fi
