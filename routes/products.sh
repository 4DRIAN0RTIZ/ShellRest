#!/bin/bash

register_route "GET"    "/products"      "get_products"
register_route "POST"   "/products"      "post_products"
register_route "GET"    "/products/{id}" "get_product"
register_route "PUT"    "/products/{id}" "put_product"
register_route "DELETE" "/products/{id}" "delete_product"

get_products() {
    local result
    result=$(db_select "products" "id, name, description, price, stock_quantity")
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

get_product() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(db_select "products" "id, name, description, price, stock_quantity" "id = $id")
    if [ -z "$result" ] || [ "$result" = "[]" ]; then
        http_response "404 Not Found" "application/json" "$(json_error "Product not found")"
    else
        http_response "200 OK" "application/json" "$result"
    fi
}

post_products() {
    local body="$1"

    if ! validate_required_fields "$body" "name" "price"; then
        http_response "400 Bad Request" "application/json" "$(json_error "name and price are required")"
        return
    fi

    local name price description stock_quantity
    name=$(get_json_field "$body" "name")
    price=$(get_json_field "$body" "price")
    description=$(get_json_field "$body" "description")
    stock_quantity=$(get_json_field "$body" "stock_quantity")
    stock_quantity="${stock_quantity:-0}"

    db_insert "products" "name, description, price, stock_quantity" \
        "$(safe_sql_string "$name"), $(safe_sql_string "$description"), $price, $stock_quantity"
    local id
    id=$(db_get_last_insert_id)
    http_response "201 Created" "application/json" \
        "$(db_select "products" "id, name, description, price, stock_quantity" "id = $id")"
}

put_product() {
    local id="$1" body="$2"
    validate_path_param "$id" || return

    if ! validate_required_fields "$body" "name" "price"; then
        http_response "400 Bad Request" "application/json" "$(json_error "name and price are required")"
        return
    fi

    local name price description stock_quantity
    name=$(get_json_field "$body" "name")
    price=$(get_json_field "$body" "price")
    description=$(get_json_field "$body" "description")
    stock_quantity=$(get_json_field "$body" "stock_quantity")
    stock_quantity="${stock_quantity:-0}"

    db_update "products" \
        "name = $(safe_sql_string "$name"), description = $(safe_sql_string "$description"), price = $price, stock_quantity = $stock_quantity" \
        "id = $id"

    local changes
    changes=$(db_get_changes)
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "200 OK" "application/json" \
            "$(db_select "products" "id, name, description, price, stock_quantity" "id = $id")"
    else
        http_response "404 Not Found" "application/json" "$(json_error "Product not found")"
    fi
}

delete_product() {
    local id="$1"
    validate_path_param "$id" || return
    db_delete "products" "id = $id"
    local changes
    changes=$(db_get_changes)
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "204 No Content" "application/json" ""
    else
        http_response "404 Not Found" "application/json" "$(json_error "Product not found")"
    fi
}
