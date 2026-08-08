#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../shellrest/models/products.sh"

register_route "GET"    "/products"      "get_products"
register_route "POST"   "/products"      "post_products"
register_route "GET"    "/products/{id}" "get_product"
register_route "PUT"    "/products/{id}" "put_product"
register_route "DELETE" "/products/{id}" "delete_product"

get_products() {
    local result
    result=$(products_find_all)
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

get_product() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(products_find "$id")
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

    local id
    id=$(products_create "$name" "$description" "$price" "$stock_quantity")
    http_response "201 Created" "application/json" \
        "$(products_find "$id")"
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

    local changes
    changes=$(products_update "$id" "$name" "$description" "$price" "$stock_quantity")
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "200 OK" "application/json" \
            "$(products_find "$id")"
    else
        http_response "404 Not Found" "application/json" "$(json_error "Product not found")"
    fi
}

delete_product() {
    local id="$1"
    validate_path_param "$id" || return
    local changes
    changes=$(products_delete "$id")
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "204 No Content" "application/json" ""
    else
        http_response "404 Not Found" "application/json" "$(json_error "Product not found")"
    fi
}
