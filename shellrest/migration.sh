#!/bin/bash

# Migration framework for Bash API
# Get the directory of this script
FRAMEWORK_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$FRAMEWORK_DIR/database.sh"

# Migration tracking table
MIGRATION_TABLE="migrations"

init_migration_system() {
    execute_query "CREATE TABLE IF NOT EXISTS $MIGRATION_TABLE (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        migration TEXT NOT NULL UNIQUE,
        executed_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );"
    echo "Migration system initialized"
}

is_migration_executed() {
    local migration_name="$1"
    local count=$(execute_query "SELECT COUNT(*) FROM $MIGRATION_TABLE WHERE migration = '$migration_name';")
    [ "$count" -gt 0 ]
}

mark_migration_executed() {
    local migration_name="$1"
    execute_query "INSERT INTO $MIGRATION_TABLE (migration) VALUES ('$migration_name');"
    echo "Migration $migration_name marked as executed"
}

rollback_migration() {
    local migration_name="$1"
    execute_query "DELETE FROM $MIGRATION_TABLE WHERE migration = '$migration_name';"
    echo "Migration $migration_name rolled back"
}

get_executed_migrations() {
    execute_query "SELECT migration FROM $MIGRATION_TABLE ORDER BY id;"
}

# Schema builder functions
create_table() {
    local table_name="$1"
    local columns="$2"
    local constraints="$3"
    
    local sql="CREATE TABLE IF NOT EXISTS $table_name ("
    sql="$sql$columns"
    
    if [ -n "$constraints" ]; then
        sql="$sql, $constraints"
    fi
    
    sql="$sql);"
    
    echo "Creating table: $table_name"
    execute_query "$sql"
}

drop_table() {
    local table_name="$1"
    echo "Dropping table: $table_name"
    execute_query "DROP TABLE IF EXISTS $table_name;"
}

add_column() {
    local table_name="$1"
    local column_definition="$2"
    echo "Adding column to $table_name: $column_definition"
    execute_query "ALTER TABLE $table_name ADD COLUMN $column_definition;"
}

drop_column() {
    local table_name="$1"
    local column_name="$2"
    echo "Dropping column $column_name from $table_name"
    execute_query "ALTER TABLE $table_name DROP COLUMN $column_name;"
}

rename_table() {
    local old_name="$1"
    local new_name="$2"
    echo "Renaming table from $old_name to $new_name"
    execute_query "ALTER TABLE $old_name RENAME TO $new_name;"
}

# Column type helpers
id_column() {
    echo "id INTEGER PRIMARY KEY AUTOINCREMENT"
}

string_column() {
    local name="$1"
    local length="${2:-255}"
    local nullable="${3:-true}"
    
    local definition="$name TEXT"
    if [ "$nullable" = "false" ]; then
        definition="$definition NOT NULL"
    fi
    echo "$definition"
}

integer_column() {
    local name="$1"
    local nullable="${2:-true}"
    
    local definition="$name INTEGER"
    if [ "$nullable" = "false" ]; then
        definition="$definition NOT NULL"
    fi
    echo "$definition"
}

decimal_column() {
    local name="$1"
    local precision_scale="${2:-10,2}"
    local nullable="${3:-true}"
    
    local definition="$name DECIMAL($precision_scale)"
    if [ "$nullable" = "false" ]; then
        definition="$definition NOT NULL"
    fi
    echo "$definition"
}

boolean_column() {
    local name="$1"
    local default="${2:-}"
    local nullable="${3:-true}"
    
    local definition="$name BOOLEAN"
    if [ "$nullable" = "false" ]; then
        definition="$definition NOT NULL"
    fi
    if [ -n "$default" ]; then
        definition="$definition DEFAULT $default"
    fi
    echo "$definition"
}

datetime_column() {
    local name="$1"
    local default="${2:-}"
    local nullable="${3:-true}"
    
    local definition="$name DATETIME"
    if [ "$nullable" = "false" ]; then
        definition="$definition NOT NULL"
    fi
    if [ "$default" = "now" ]; then
        definition="$definition DEFAULT CURRENT_TIMESTAMP"
    elif [ -n "$default" ]; then
        definition="$definition DEFAULT '$default'"
    fi
    echo "$definition"
}

timestamps_columns() {
    echo "$(datetime_column "created_at" "now" false), $(datetime_column "updated_at" "now" false)"
}

foreign_key() {
    local column="$1"
    local ref_table="$2"
    local ref_column="${3:-id}"
    echo "FOREIGN KEY ($column) REFERENCES $ref_table($ref_column)"
}

unique_constraint() {
    local columns="$1"
    echo "UNIQUE ($columns)"
}

# Index functions
create_index() {
    local index_name="$1"
    local table_name="$2"
    local columns="$3"
    local unique="${4:-false}"
    
    local sql="CREATE"
    if [ "$unique" = "true" ]; then
        sql="$sql UNIQUE"
    fi
    sql="$sql INDEX IF NOT EXISTS $index_name ON $table_name ($columns);"
    
    echo "Creating index: $index_name"
    execute_query "$sql"
}

drop_index() {
    local index_name="$1"
    echo "Dropping index: $index_name"
    execute_query "DROP INDEX IF EXISTS $index_name;"
}
