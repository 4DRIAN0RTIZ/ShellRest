---
type: Project Overview
title: ShellRest overview
description: ShellRest is a Bash-based REST API framework with routing, middleware, validation, SQLite-backed database helpers, timestamped migrations, and an artisan-style CLI.
tags: [bash, rest-api, sqlite, cli, routing, middleware, migrations]
---

# ShellRest overview

ShellRest is a REST API framework written entirely in Bash. The repository positions it as a framework with no runtime beyond standard Unix tools.

## What it provides

- HTTP server entry point via `server.sh`
- Request handling through `api.sh`
- Router support for path parameters, query strings, and wildcard patterns
- Database helpers for SQLite operations such as select, insert, update, delete, joins, and aggregations
- Middleware pipeline with logging, CORS, and auth support
- Migration commands for timestamped schema files and lifecycle actions such as run, rollback, fresh, and reset
- Validation helpers for common request-data checks
- A unified CLI at `./bin/shellrest`

## Primary entry points

| Path | Purpose |
|------|---------|
| `server.sh` | Starts the TCP server and listens on the configured port |
| `api.sh` | Handles each incoming request |
| `bin/shellrest` | Unified CLI for route listing, controller generation, migration generation, and migration management |

## Configuration model

The README documents a zero-required-variable configuration model with defaults for:

- `API_PORT`
- `DB_FILE`
- `LOG_FILE`
- `DEBUG`
- `CORS_ORIGIN`

The README also notes that `.env` is optional because all variables have defaults.

## Documentation relationships

- See `openwiki/cli.md` for command details.
- See `openwiki/runtime.md` for server startup and request handling.
- See `openwiki/project-structure.md` for the repository layout described in the README.
