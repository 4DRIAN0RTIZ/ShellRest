#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    _common_setup

    source "$PROJECT_ROOT/shellrest/config.sh"
    source "$PROJECT_ROOT/shellrest/database.sh"
    source "$PROJECT_ROOT/shellrest/migration.sh"
    source "$PROJECT_ROOT/shellrest/cli/migrate.sh"
    source "$PROJECT_ROOT/shellrest/utils.sh"
    source "$PROJECT_ROOT/shellrest/models/products.sh"

    MIGRATIONS_DIR="$PROJECT_ROOT/migrations"
    load_config
    init_database
    init_migration_system
    run_pending_migrations >/dev/null
}

teardown() {
    _common_teardown
}

@test "products_find_all returns [] on empty table" {
    result="$(products_find_all)"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "products_create inserts a row and products_find returns it" {
    id="$(products_create "Widget" "A useful widget" 9.99 5)"
    result="$(products_find "$id")"
    echo "$result" | grep -q "Widget"
}

@test "products_find_all returns rows after insert" {
    products_create "Widget" "desc" 9.99 5
    result="$(products_find_all)"
    echo "$result" | grep -q "Widget"
}

@test "products_find returns [] for missing id" {
    result="$(products_find 9999)"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "products_update changes an existing row" {
    id="$(products_create "Widget" "desc" 9.99 5)"
    changes="$(products_update "$id" "Widget2" "desc2" 19.99 10)"
    assert_equal "$changes" "1"
    result="$(products_find "$id")"
    echo "$result" | grep -q "Widget2"
}

@test "products_update returns 0 changes for missing id" {
    changes="$(products_update 9999 "Widget" "desc" 9.99 5)"
    assert_equal "$changes" "0"
}

@test "products_delete removes an existing row" {
    id="$(products_create "Widget" "desc" 9.99 5)"
    changes="$(products_delete "$id")"
    assert_equal "$changes" "1"
    result="$(products_find "$id")"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "products_delete returns 0 changes for missing id" {
    changes="$(products_delete 9999)"
    assert_equal "$changes" "0"
}
