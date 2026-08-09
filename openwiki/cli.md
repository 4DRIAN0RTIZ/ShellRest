---
type: CLI Reference
title: ShellRest CLI
description: Reference for the unified `shellrest` command, including route listing, controller generation, migration generation, and migration lifecycle commands.
tags: [bash, cli, migrations, routing]
---

# ShellRest CLI

The repository exposes a single artisan-style entry point at `./bin/shellrest`.

## Commands

| Command | Description |
|---------|-------------|
| `route:list` | Lists all registered routes |
| `make:controller <name> [singular]` | Generates `routes/<name>.sh` with CRUD stubs |
| `make:migration <name> [table]` | Generates a new migration file |
| `migrate [run|status|rollback|fresh|reset]` | Runs and manages migrations |
| `--help` / `help` | Shows command help |

## Examples

```bash
shellrest route:list
shellrest make:controller products
shellrest make:migration create_products_table products
shellrest migrate status
```

## Source evidence

The CLI help text in `bin/shellrest` defines the user-facing command set and examples. The README repeats the same command list and describes the CLI as the unified entry point.
