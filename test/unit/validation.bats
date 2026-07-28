#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    _common_setup
    source "$PROJECT_ROOT/shellrest/validation.sh"
}

teardown() {
    _common_teardown
}

@test "validate_email accepts a well-formed address" {
    run validate_email "user@example.com"
    assert_success
}

@test "validate_email rejects a malformed address" {
    run validate_email "not-an-email"
    assert_failure
}

@test "validate_integer accepts a numeric string" {
    run validate_integer "42"
    assert_success
}

@test "validate_integer rejects a non-numeric string" {
    run validate_integer "12a"
    assert_failure
}

@test "sanitize_input strips control characters" {
    result="$(sanitize_input $'hello\x01world')"
    assert_equal "$result" "helloworld"
}

@test "validate_json accepts valid JSON" {
    run validate_json '{"a":1}'
    assert_success
}

@test "validate_json rejects invalid JSON" {
    run validate_json '{a:1}'
    assert_failure
}
