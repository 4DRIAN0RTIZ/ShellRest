#!/bin/bash

# Scaffold generator script — creates a new ShellRest project structure
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <project_name>"
    echo "Example:"
    echo "  $0 my-api"
    exit 1
fi

project_name="$1"
target_dir="$project_name"

if [ -d "$target_dir" ]; then
    echo "Error: directory '$target_dir' already exists."
    exit 1
fi

mkdir -p "$target_dir"

cp "$SOURCE_DIR/server.sh" "$target_dir/"
cp "$SOURCE_DIR/api.sh" "$target_dir/"

cp -r "$SOURCE_DIR/shellrest" "$target_dir/"
cp -r "$SOURCE_DIR/bin" "$target_dir/"

mkdir -p "$target_dir/routes"
cp "$SOURCE_DIR/routes/root.sh" "$target_dir/routes/"

mkdir -p "$target_dir/migrations"

chmod +x "$target_dir"/*.sh
chmod +x "$target_dir/bin/shellrest"

echo "Project '$project_name' created at ./$target_dir"
