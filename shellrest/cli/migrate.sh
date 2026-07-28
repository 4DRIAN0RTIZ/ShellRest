#!/bin/bash

# migrate command library — used by bin/shellrest

_migrate_help() {
    echo "Migration Commands:"
    echo "  shellrest migrate                 - Run all pending migrations"
    echo "  shellrest migrate status          - Show migration status"
    echo "  shellrest migrate rollback [name]  - Rollback specific migration or last one"
    echo "  shellrest migrate fresh           - Drop all tables and re-run all migrations"
    echo "  shellrest migrate reset           - Rollback all migrations"
    echo "  shellrest migrate --help          - Show this help"
    echo ""
    echo "Examples:"
    echo "  shellrest migrate"
    echo "  shellrest migrate rollback 20231201_120000_create_users_table.sh"
    echo "  shellrest migrate fresh"
}

run_pending_migrations() {
    local migrations_run=0

    if [ ! -d "$MIGRATIONS_DIR" ]; then
        echo "No migrations directory found."
        return 0
    fi

    echo "Checking for pending migrations..."

    # Get all migration files sorted by name (timestamp)
    for migration_file in $(ls "$MIGRATIONS_DIR"/*.sh 2>/dev/null | sort); do
        local migration_name=$(basename "$migration_file")

        if ! is_migration_executed "$migration_name"; then
            echo ""
            echo "Running migration: $migration_name"

            # Execute the migration
            if bash "$migration_file" up; then
                mark_migration_executed "$migration_name"
                migrations_run=$((migrations_run + 1))
                echo "✓ Migration completed: $migration_name"
            else
                echo "✗ Migration failed: $migration_name"
                return 1
            fi
        fi
    done

    if [ $migrations_run -eq 0 ]; then
        echo "No pending migrations."
    else
        echo ""
        echo "Completed $migrations_run migrations."
    fi
}

show_migration_status() {
    echo "Migration Status:"
    echo "=================="

    if [ ! -d "$MIGRATIONS_DIR" ]; then
        echo "No migrations directory found."
        return 0
    fi

    # Get executed migrations
    local executed_migrations=$(get_executed_migrations)

    # Show all migration files
    for migration_file in $(ls "$MIGRATIONS_DIR"/*.sh 2>/dev/null | sort); do
        local migration_name=$(basename "$migration_file")

        if is_migration_executed "$migration_name"; then
            echo "✓ $migration_name (executed)"
        else
            echo "✗ $migration_name (pending)"
        fi
    done
}

rollback_migration_by_name() {
    local migration_name="$1"
    local migration_file="$MIGRATIONS_DIR/$migration_name"

    if [ ! -f "$migration_file" ]; then
        echo "Migration file not found: $migration_file"
        return 1
    fi

    if ! is_migration_executed "$migration_name"; then
        echo "Migration was not executed: $migration_name"
        return 1
    fi

    echo "Rolling back migration: $migration_name"

    if bash "$migration_file" down; then
        rollback_migration "$migration_name"
        echo "✓ Migration rolled back: $migration_name"
    else
        echo "✗ Migration rollback failed: $migration_name"
        return 1
    fi
}

rollback_last_migration() {
    local last_migration=$(execute_query "SELECT migration FROM $MIGRATION_TABLE ORDER BY id DESC LIMIT 1;")

    if [ -z "$last_migration" ]; then
        echo "No migrations to rollback."
        return 0
    fi

    rollback_migration_by_name "$last_migration"
}

fresh_migrations() {
    echo "WARNING: This will drop all tables and re-run all migrations."
    echo "This operation cannot be undone!"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi

    echo "Dropping all tables..."

    # Get all table names except sqlite_master and sqlite_sequence
    local tables=$(execute_query "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")

    # Drop each table
    while IFS= read -r table; do
        if [ -n "$table" ]; then
            echo "Dropping table: $table"
            execute_query "DROP TABLE IF EXISTS $table;"
        fi
    done <<< "$tables"

    echo "Re-initializing database..."
    init_database
    init_migration_system

    echo "Running all migrations..."
    run_pending_migrations
}

reset_migrations() {
    echo "Rolling back all migrations..."

    # Get all executed migrations in reverse order
    local migrations=$(execute_query "SELECT migration FROM $MIGRATION_TABLE ORDER BY id DESC;")

    while IFS= read -r migration; do
        if [ -n "$migration" ]; then
            rollback_migration_by_name "$migration"
        fi
    done <<< "$migrations"

    echo "All migrations have been rolled back."
}

cmd_migrate() {
    source "${_PROJECT_ROOT}/shellrest/config.sh"
    source "${_PROJECT_ROOT}/shellrest/database.sh"
    source "${_PROJECT_ROOT}/shellrest/migration.sh"

    MIGRATIONS_DIR="${_PROJECT_ROOT}/migrations"

    load_config
    init_database
    init_migration_system

    local sub="${1:-run}"
    [ $# -gt 0 ] && shift

    case "$sub" in
        "run"|"")
            run_pending_migrations
            ;;
        "status")
            show_migration_status
            ;;
        "rollback")
            if [ -n "$1" ]; then
                rollback_migration_by_name "$1"
            else
                rollback_last_migration
            fi
            ;;
        "fresh")
            fresh_migrations
            ;;
        "reset")
            reset_migrations
            ;;
        "--help"|"help")
            _migrate_help
            ;;
        *)
            echo "Unknown migrate subcommand: $sub" >&2
            _migrate_help
            return 1
            ;;
    esac
}
