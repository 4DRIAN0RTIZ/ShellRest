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

    MIGRATIONS_DIR="$PROJECT_ROOT/migrations"
    load_config
    init_database
    init_migration_system
    run_pending_migrations >/dev/null
}

teardown() {
    _common_teardown
}

@test "users_find_all returns [] on empty table" {
    result="$(users_find_all)"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "users_create inserts a row and users_find returns it" {
    id="$(users_create "alice" "alice@example.com")"
    result="$(users_find "$id")"
    echo "$result" | grep -q "alice"
}

@test "users_find_all returns rows after insert" {
    users_create "alice" "alice@example.com"
    result="$(users_find_all)"
    echo "$result" | grep -q "alice"
}

@test "users_find returns [] for missing id" {
    result="$(users_find 9999)"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "users_update changes an existing row" {
    id="$(users_create "alice" "alice@example.com")"
    changes="$(users_update "$id" "alice2" "alice2@example.com")"
    assert_equal "$changes" "1"
    result="$(users_find "$id")"
    echo "$result" | grep -q "alice2"
}

@test "users_update returns 0 changes for missing id" {
    changes="$(users_update 9999 "alice" "alice@example.com")"
    assert_equal "$changes" "0"
}

@test "users_delete removes an existing row" {
    id="$(users_create "alice" "alice@example.com")"
    changes="$(users_delete "$id")"
    assert_equal "$changes" "1"
    result="$(users_find "$id")"
    [ -z "$result" ] && result="[]"
    assert_equal "$result" "[]"
}

@test "users_delete returns 0 changes for missing id" {
    changes="$(users_delete 9999)"
    assert_equal "$changes" "0"
}
