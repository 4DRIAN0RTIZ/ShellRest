# Tests

Bash tests for shellrest, using [bats-core](https://github.com/bats-core/bats-core).

## Setup

```sh
git submodule update --init --recursive
```

## Run

```sh
bats test/unit
```

(Don't run `bats -r test/` — the `-r` recursive flag would also try to run
the bats-support/bats-assert submodules' own test suites.)

Requires `bats`, `jq`, and `sqlite3` on `PATH`.

## Writing tests

- Put unit tests for `shellrest/<module>.sh` in `test/unit/<module>.bats`.
- Load `test/test_helper/common_setup.bash` and call `_common_setup` in `setup()`
  (and `_common_teardown` in `teardown()`). It loads bats-support/bats-assert,
  exports `PROJECT_ROOT`, and points `DB_FILE` at a temp file so tests never
  touch the real `sqlite_data.db`.
- Source only the module under test, not the full `api.sh` bootstrap, to avoid
  pulling in `.env` loading and logging side effects.
