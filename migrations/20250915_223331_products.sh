#!/bin/bash

# Migration: products
# Created: Mon Sep 15 10:33:31 PM CST 2025

source "$(dirname "$0")/../framework/migration.sh"

up() {
    echo "Running migration: products"
    
    # Add your migration logic here
    # Examples:
    # create_table "table_name" "$(id_column), $(string_column "name")" ""
    # add_column "table_name" "$(string_column "new_column")"
    # create_index "idx_name" "table_name" "column_name"
    local columns="$(id_column),
    $(string_column "name"),
    $(string_column "description" "255" "NULL"),
    $(decimal_column "price" "10,2"),
    $(integer_column "stock_quantity" "0"),
    $(timestamps_columns)"

    create_table "products" "$columns"

}

down() {
    echo "Rolling back migration: products"
    
    # Add your rollback logic here
    # Examples:
    # drop_table "table_name"
    # drop_index "idx_name"
}

# Execute the migration function based on the argument
if [ "$1" = "up" ]; then
    up
elif [ "$1" = "down" ]; then
    down
else
    echo "Usage: $0 {up|down}"
    exit 1
fi
