#!/bin/bash

products_find_all() {
    db_select "products" "id, name, description, price, stock_quantity"
}

products_find() {
    local id="$1"
    db_select "products" "id, name, description, price, stock_quantity" "id = $id"
}

products_create() {
    local name="$1" description="$2" price="$3" stock_quantity="$4"
    db_insert "products" "name, description, price, stock_quantity" \
        "$(safe_sql_string "$name"), $(safe_sql_string "$description"), $price, $stock_quantity"
}

products_update() {
    local id="$1" name="$2" description="$3" price="$4" stock_quantity="$5"
    db_update "products" \
        "name = $(safe_sql_string "$name"), description = $(safe_sql_string "$description"), price = $price, stock_quantity = $stock_quantity" \
        "id = $id"
}

products_delete() {
    local id="$1"
    db_delete "products" "id = $id"
}
