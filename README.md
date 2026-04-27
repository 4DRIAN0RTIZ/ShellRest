<img width="1920" height="1080" alt="logo" src="https://github.com/user-attachments/assets/a5894643-b1d3-4022-90c5-e22c2c128f07" />

# ShellRest

A REST API framework written entirely in Bash. No runtime beyond standard Unix tools.

**→ [Full Documentation](https://shellrest.cuevaneander.tech)**

---

## Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| `bash` | 5+ | Runtime |
| `sqlite3` | 3+ | Database |
| `jq` | any | JSON parsing |
| `nc` | OpenBSD | HTTP server |

## Quick Start

```bash
# Run migrations
./migrate.sh

# Start server (default port 8082)
./server.sh
```

```bash
# Test it
curl http://localhost:8082/users
curl -X POST http://localhost:8082/users \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","email":"alice@example.com"}'
```

## Features

- **Router** — path params (`{id}`), query strings, wildcard patterns
- **Database** — `db_select`, `db_insert`, `db_update`, `db_delete`, JOIN helpers, aggregations
- **Middleware** — composable pipeline, built-in logging + CORS + auth
- **Migrations** — timestamped files, schema builder, `up`/`down`, `fresh`/`reset`
- **Validation** — JSON, email, integer, required fields, path param guard
- **Config** — `.env` file, zero required vars, sensible defaults

## Configuration

```bash
cp .env.example .env  # optional — all vars have defaults
```

| Variable | Default | Description |
|----------|---------|-------------|
| `API_PORT` | `8082` | TCP port |
| `DB_FILE` | `sqlite_data.db` | SQLite path |
| `LOG_FILE` | `access.log` | Access log path |
| `DEBUG` | `false` | Enables `debug_log()` |
| `CORS_ORIGIN` | `*` | CORS allowed origin |

## Project Structure

```
shellrest/
├── server.sh          # TCP server
├── api.sh             # Per-request entry point
├── migrate.sh         # Migration runner
├── make_migration.sh  # Migration generator
├── shellrest/         # Framework core
│   ├── config.sh
│   ├── http.sh
│   ├── router.sh
│   ├── database.sh
│   ├── middleware.sh
│   ├── migration.sh
│   ├── validation.sh
│   └── utils.sh
├── routes/            # Auto-loaded route files
└── migrations/        # Timestamped migration files
```

## License

MIT — [4drian0rtiz](https://github.com/4drian0rtiz)
