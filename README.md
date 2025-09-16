<img width="1920" height="1080" alt="logo" src="https://github.com/user-attachments/assets/a5894643-b1d3-4022-90c5-e22c2c128f07" />

# ShellRest

A lightweight REST API framework written entirely in Bash. No runtime dependencies beyond standard Unix tools.

## Requirements

- Bash 4.2+
- `sqlite3` — database
- `jq` — JSON parsing
- `nc` (GNU netcat) — HTTP server

## Project Structure

```
shellrest/
├── server.sh              # HTTP server entry point
├── api.sh                 # Request handler and dispatcher
├── migrate.sh             # Migration runner
├── make_migration.sh      # Migration file generator
├── config.env.example     # Configuration template
├── framework/             # Core framework
│   ├── config.sh          # Configuration loader
│   ├── http.sh            # HTTP response helpers
│   ├── router.sh          # Route registration and dispatch
│   ├── database.sh        # SQLite driver
│   ├── middleware.sh       # Middleware stack
│   ├── migration.sh       # Schema builder
│   ├── validation.sh      # Input validation
│   └── utils.sh           # DB and JSON utilities
├── routes/                # Route definitions (auto-loaded)
│   ├── root.sh
│   ├── users.sh
│   ├── products.sh
│   └── orders.sh
└── migrations/            # Migration files (timestamped)
```

## Setup

```bash
cp .env.example .env
```

Edit `.env`:

```env
API_PORT=8082
API_HOST=localhost
DB_FILE=sqlite_data.db
LOG_FILE=access.log
DEBUG=false
```

CORS headers are configurable via environment variables:

```env
CORS_ORIGIN=*
CORS_METHODS=GET, POST, PUT, DELETE, OPTIONS
CORS_HEADERS=Content-Type, Authorization
```

## Starting the Server

```bash
./server.sh
```

## Defining Routes

Create a file in `routes/` (e.g. `routes/products.sh`). Each file is sourced automatically at startup — register your routes and define their handlers.

```bash
#!/bin/bash

source "framework/http.sh"
source "framework/utils.sh"

register_route "GET"    "/products"     "get_products"
register_route "POST"   "/products"     "post_products"
register_route "GET"    "/products/{id}" "get_product"
register_route "PUT"    "/products/{id}" "put_product"
register_route "DELETE" "/products/{id}" "delete_product"

get_products() {
    local result
    result=$(db_select "products" "*")
    [ -z "$result" ] && result="[]"
    http_response "200 OK" "application/json" "$result"
}

post_products() {
    local body="$1"

    if ! validate_required_fields "$body" "name" "price"; then
        http_response "400 Bad Request" "application/json" "$(json_error "name and price are required")"
        return
    fi

    local name price
    name=$(get_json_field "$body" "name")
    price=$(get_json_field "$body" "price")

    db_insert "products" "name, price" "$(safe_sql_string "$name"), $price"
    local id
    id=$(db_get_last_insert_id)
    http_response "201 Created" "application/json" "$(db_select "products" "*" "id = $id")"
}

get_product() {
    local id="$1"
    validate_path_param "$id" || return
    local result
    result=$(db_select "products" "*" "id = $id")
    if [ -z "$result" ] || [ "$result" = "[]" ]; then
        http_response "404 Not Found" "application/json" "$(json_error "Not found")"
    else
        http_response "200 OK" "application/json" "$result"
    fi
}

put_product() {
    local id="$1" body="$2"
    validate_path_param "$id" || return
    validate_required_fields "$body" "name" "price" || {
        http_response "400 Bad Request" "application/json" "$(json_error "name and price are required")"
        return
    }
    local name price
    name=$(get_json_field "$body" "name")
    price=$(get_json_field "$body" "price")
    db_update "products" "name = $(safe_sql_string "$name"), price = $price" "id = $id"
    local changes
    changes=$(db_get_changes)
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "200 OK" "application/json" "$(db_select "products" "*" "id = $id")"
    else
        http_response "404 Not Found" "application/json" "$(json_error "Not found")"
    fi
}

delete_product() {
    local id="$1"
    validate_path_param "$id" || return
    db_delete "products" "id = $id"
    local changes
    changes=$(db_get_changes)
    if [ "${changes:-0}" -gt 0 ]; then
        http_response "204 No Content" "application/json" ""
    else
        http_response "404 Not Found" "application/json" "$(json_error "Not found")"
    fi
}
```

### Route Parameters

Use `{param}` placeholders in patterns. Parameters are passed positionally to the handler before the body:

```bash
register_route "GET" "/users/{id}/posts/{post_id}" "get_user_post"

get_user_post() {
    local user_id="$1"
    local post_id="$2"
    local body="$3"
    # ...
}
```

## Middleware

Middleware runs before every request. Return `0` to continue, `1` to halt (response must already be sent).

```bash
rate_limit_middleware() {
    local method="$1"
    local path="$2"
    # local body="$3"

    # example: block a specific IP via a header
    # if [ ... ]; then
    #     http_response "429 Too Many Requests" "application/json" "$(json_error "Rate limit exceeded")"
    #     return 1
    # fi
    return 0
}

add_middleware "rate_limit_middleware"
```

Built-in middleware (registered in `api.sh`):

| Middleware | Behavior |
|------------|----------|
| `logging_middleware` | Appends `METHOD PATH` to `$LOG_FILE` |
| `cors_middleware` | Handles `OPTIONS` preflight, returns 204 |
| `auth_middleware` | Blocks `/protected/*` paths without `Authorization` header |

## Validation

```bash
# Validate JSON body is parseable
if ! validate_json "$body"; then
    http_response "400 Bad Request" "application/json" "$(json_error "Invalid JSON")"
    return
fi

# Require specific fields (null-safe)
if ! validate_required_fields "$body" "name" "email"; then
    http_response "400 Bad Request" "application/json" "$(json_error "name and email are required")"
    return
fi

# Type validators (return 0/1)
validate_email   "$email"  # regex check
validate_integer "$value"  # digits only

# Validate and reject non-integer path param automatically
validate_path_param "$id" || return

# Strip control characters from user input
clean=$(sanitize_input "$raw_input")
```

## Database

All helpers use `$DB_FILE` (set by `load_config`) and propagate SQLite errors to stderr.

### Basic Operations

```bash
# SELECT — returns JSON array by default
users=$(db_select "users" "id, name" "active = 1")

# INSERT
db_insert "users" "name, email" "$(safe_sql_string "$name"), $(safe_sql_string "$email")"
last_id=$(db_get_last_insert_id)

# UPDATE
db_update "users" "name = $(safe_sql_string "$name")" "id = $id"
changes=$(db_get_changes)

# DELETE
db_delete "users" "id = $id"

# EXISTS / COUNT
db_exists "users" "email = $(safe_sql_string "$email")"
count=$(db_count "users" "active = 1")
```

### JOINs

```bash
# INNER JOIN
result=$(db_inner_join \
    "u.name, p.title" \
    "users u" "posts p" \
    "u.id = p.user_id" \
    "u.active = 1" \
    "u.name")

# LEFT JOIN
result=$(db_left_join \
    "u.name, COUNT(p.id) as post_count" \
    "users u" "posts p" \
    "u.id = p.user_id" \
    "" "u.name")

# Multiple JOINs
joins="INNER JOIN posts p ON u.id = p.user_id LEFT JOIN categories c ON p.category_id = c.id"
result=$(db_multi_join \
    "u.name, p.title, c.name as category" \
    "users u" "$joins" \
    "u.active = 1" \
    "u.id" "" "u.name" "10")

# Raw SQL
result=$(db_raw_query "SELECT id, name FROM users ORDER BY created_at DESC LIMIT 5")
```

### Response Helpers

```bash
http_response "200 OK"  "application/json" "$(json_success "Done")"
http_response "400 Bad Request" "application/json" "$(json_error "Invalid input")"
```

## Migrations

### Create a migration

```bash
./make_migration.sh create_posts_table posts
./make_migration.sh add_email_to_users
```

### Run migrations

```bash
./migrate.sh           # run all pending
./migrate.sh status    # show executed migrations
./migrate.sh rollback  # revert last
./migrate.sh reset     # revert all
./migrate.sh fresh     # reset + re-run all
```

### Migration file structure

```bash
#!/bin/bash

source "$(dirname "$0")/../framework/migration.sh"

up() {
    local columns
    columns="$(id_column),
    $(string_column "title" 255 false),
    $(string_column "content" 0 true),
    $(integer_column "user_id" false),
    $(boolean_column "published" 0 false),
    $(timestamps_columns)"

    local constraints
    constraints="$(foreign_key "user_id" "users" "id")"

    create_table "posts" "$columns" "$constraints"
    create_index "idx_posts_user_id" "posts" "user_id"
}

down() {
    drop_table "posts"
}

if   [ "$1" = "up"   ]; then up
elif [ "$1" = "down" ]; then down
else echo "Usage: $0 {up|down}"; exit 1
fi
```

### Column helpers

```bash
$(id_column)                              # INTEGER PRIMARY KEY AUTOINCREMENT
$(string_column  "name"   255   false)    # TEXT NOT NULL
$(string_column  "bio"    0     true)     # TEXT
$(integer_column "stock"  false)          # INTEGER NOT NULL
$(decimal_column "price"  "10,2" false)   # DECIMAL(10,2) NOT NULL
$(boolean_column "active" 1     false)    # BOOLEAN DEFAULT 1 NOT NULL
$(datetime_column "published_at" "" true) # DATETIME
$(datetime_column "created_at" "now" false) # DATETIME DEFAULT CURRENT_TIMESTAMP
$(timestamps_columns)                     # created_at, updated_at (both NOT NULL DEFAULT NOW)
$(foreign_key "user_id" "users" "id")     # FOREIGN KEY constraint
$(unique_constraint "email")              # UNIQUE constraint
```

## License

MIT
