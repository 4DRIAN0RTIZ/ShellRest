---
type: Repository Structure
title: ShellRest project structure
description: High-level map of the repository layout documented in the README, including core scripts, framework modules, routes, and migrations.
tags: [repository, structure, bash, routes, migrations]
---

# ShellRest project structure

The README documents the repository layout as follows:

```text
shellrest/
├── bin/
│   └── shellrest       # Unified CLI (route:list, make:controller, make:migration, migrate)
├── server.sh           # TCP server
├── api.sh              # Per-request entry point
├── shellrest/          # Framework core
│   ├── config.sh
│   ├── http.sh
│   ├── router.sh
│   ├── database.sh
│   ├── middleware.sh
│   ├── migration.sh
│   ├── validation.sh
│   ├── utils.sh
│   └── cli/            # CLI command implementations
├── routes/             # Auto-loaded route files
└── migrations/         # Timestamped migration files
```

## Key areas

- `bin/shellrest` contains the unified CLI.
- `server.sh` and `api.sh` are the runtime entry points.
- `shellrest/` contains the framework core modules.
- `routes/` holds route files that are auto-loaded.
- `migrations/` holds timestamped migration files.
