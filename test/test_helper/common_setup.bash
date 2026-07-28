_common_setup() {
    load "${BATS_TEST_DIRNAME}/../test_helper/bats-support/load"
    load "${BATS_TEST_DIRNAME}/../test_helper/bats-assert/load"

    PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    export PROJECT_ROOT

    DB_FILE="$(mktemp -u "${BATS_TMPDIR:-/tmp}/shellrest-test-XXXXXX.db")"
    export DB_FILE
}

_common_teardown() {
    if [ -n "$DB_FILE" ] && [ -f "$DB_FILE" ]; then
        rm -f "$DB_FILE"
    fi
    return 0
}
