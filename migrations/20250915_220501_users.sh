#!/bin/bash

# Migration: users
# Created: Mon Sep 15 10:05:01 PM CST 2025

source "$(dirname "$0")/../framework/migration.sh"

up() {
    echo "Running migration: users"

    local columns="$(id_column),
    $(string_column "username"),
    $(string_column "email"),
    $(string_column "password"),
    $(boolean_column "is_active" "1"),
    $(timestamps_columns)"

    create_table "users" "$columns"

}

down() {
    echo "Rolling back migration: users"

    drop_table "users"
}

# Execute the migration function based on the argument
if [ "$1" = "up" ]; then
    up
elif [ "$1" = "down" ]; then
    down
else
    echo "Usage: $0 {up|down}"
    exit 1
fi
