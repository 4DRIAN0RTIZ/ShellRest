#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    _common_setup

    source "$PROJECT_ROOT/shellrest/config.sh"
    source "$PROJECT_ROOT/shellrest/database.sh"
    source "$PROJECT_ROOT/shellrest/migration.sh"
    source "$PROJECT_ROOT/shellrest/cli/migrate.sh"
    source "$PROJECT_ROOT/shellrest/utils.sh"
    source "$PROJECT_ROOT/shellrest/models/users.sh"
    source "$PROJECT_ROOT/shellrest/models/products.sh"
    source "$PROJECT_ROOT/shellrest/models/orders.sh"

    MIGRATIONS_DIR="$PROJECT_ROOT/migrations"
    load_config
    init_database
    init_migration_system
    run_pending_migrations >/dev/null

    user_id="$(users_create "alice" "alice@example.com")"
    product_id="$(products_create "Widget" "desc" 9.99 5)"
}

teardown() {
    _common_teardown
}

@test "orders_find_all returns [] on empty table" {
    result="$(orders_find_all)"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "orders_create inserts a row and orders_find returns the joined view" {
    id="$(orders_create "$user_id" "$product_id" 3)"
    result="$(orders_find "$id")"
    echo "$result" | grep -q "alice"
    echo "$result" | grep -q "Widget"
}

@test "orders_find_all returns joined rows after insert" {
    orders_create "$user_id" "$product_id" 3
    result="$(orders_find_all)"
    echo "$result" | grep -q "alice"
    echo "$result" | grep -q "Widget"
}

@test "orders_find returns [] for missing id" {
    result="$(orders_find 9999)"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "orders_find_plain returns the raw row (not joined) for post_orders response" {
    id="$(orders_create "$user_id" "$product_id" 3)"
    result="$(orders_find_plain "$id")"
    echo "$result" | grep -q "\"user_id\":$user_id"
    ! echo "$result" | grep -q "alice"
}
