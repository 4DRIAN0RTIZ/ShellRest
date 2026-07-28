#!/bin/bash

# make:migration command library — used by bin/shellrest

cmd_make_migration() {
    MIGRATIONS_DIR="${_PROJECT_ROOT}/migrations"

    if [ ! -d "$MIGRATIONS_DIR" ]; then
        mkdir -p "$MIGRATIONS_DIR"
    fi

    if [ $# -eq 0 ]; then
        echo "Usage: shellrest make:migration <migration_name> [table_name]"
        echo "Examples:"
        echo "  shellrest make:migration create_users_table users"
        echo "  shellrest make:migration add_email_to_users"
        echo "  shellrest make:migration create_posts_table posts"
        return 1
    fi

    local migration_name="$1"
    local table_name="$2"

    # Generate timestamp
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local filename="${timestamp}_${migration_name}.sh"
    local filepath="$MIGRATIONS_DIR/$filename"

    # Determine migration type and generate appropriate template
    if [[ "$migration_name" == create_*_table* ]]; then
        # Create table migration
        table_name=${table_name:-$(echo "$migration_name" | sed 's/create_//;s/_table//')}

        cat > "$filepath" << EOF
#!/bin/bash

# Migration: $migration_name
# Created: $(date)

source "\$(dirname "\$0")/../shellrest/migration.sh"

up() {
    echo "Creating table: $table_name"

    # Define your table structure here
    local columns="\$(id_column)"
    columns="\$columns, \$(string_column "name" 255 false)"
    columns="\$columns, \$(timestamps_columns)"

    # Optional constraints
    local constraints=""

    create_table "$table_name" "\$columns" "\$constraints"

    # Add indexes if needed
    # create_index "idx_${table_name}_name" "$table_name" "name"
}

down() {
    echo "Dropping table: $table_name"
    drop_table "$table_name"
}

# Execute the migration function based on the argument
if [ "\$1" = "up" ]; then
    up
elif [ "\$1" = "down" ]; then
    down
else
    echo "Usage: \$0 {up|down}"
    exit 1
fi
EOF

    elif [[ "$migration_name" == add_*_to_* ]]; then
        # Add column migration
        table_name=${table_name:-$(echo "$migration_name" | sed 's/add_.*_to_//')}
        local column_name=$(echo "$migration_name" | sed 's/add_//;s/_to_.*//')

        cat > "$filepath" << EOF
#!/bin/bash

# Migration: $migration_name
# Created: $(date)

source "\$(dirname "\$0")/../shellrest/migration.sh"

up() {
    echo "Adding column $column_name to table: $table_name"

    # Define your column
    local column_definition="\$(string_column "$column_name")"

    add_column "$table_name" "\$column_definition"
}

down() {
    echo "Removing column $column_name from table: $table_name"
    # Note: SQLite doesn't support DROP COLUMN directly
    # You'll need to implement table recreation logic here
    echo "Manual rollback required for column removal in SQLite"
}

# Execute the migration function based on the argument
if [ "\$1" = "up" ]; then
    up
elif [ "\$1" = "down" ]; then
    down
else
    echo "Usage: \$0 {up|down}"
    exit 1
fi
EOF

    else
        # Generic migration template
        cat > "$filepath" << EOF
#!/bin/bash

# Migration: $migration_name
# Created: $(date)

source "\$(dirname "\$0")/../shellrest/migration.sh"

up() {
    echo "Running migration: $migration_name"

    # Add your migration logic here
    # Examples:
    # create_table "table_name" "\$(id_column), \$(string_column "name")" ""
    # add_column "table_name" "\$(string_column "new_column")"
    # create_index "idx_name" "table_name" "column_name"
}

down() {
    echo "Rolling back migration: $migration_name"

    # Add your rollback logic here
    # Examples:
    # drop_table "table_name"
    # drop_index "idx_name"
}

# Execute the migration function based on the argument
if [ "\$1" = "up" ]; then
    up
elif [ "\$1" = "down" ]; then
    down
else
    echo "Usage: \$0 {up|down}"
    exit 1
fi
EOF

    fi

    # Make the migration file executable
    chmod +x "$filepath"

    echo "Migration created: $filepath"
    echo ""
    echo "Edit the migration file and then run:"
    echo "  shellrest migrate"
    echo ""
    echo "To rollback this migration:"
    echo "  shellrest migrate rollback $filename"
}
