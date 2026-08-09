---
type: Runtime Reference
title: ShellRest runtime
description: Runtime notes for the Bash server entry point and per-request execution path used by ShellRest.
tags: [bash, runtime, server, requests]
---

# ShellRest runtime

## Startup path

`server.sh` is the long-running entry point. It:

1. Sources `shellrest/config.sh`
2. Calls `load_config`
3. Reads the configured port with `get_config "port"`
4. Prints a listen message
5. Starts `socat` with `TCP-LISTEN:${PORT},fork,reuseaddr` and `EXEC:"$(dirname "$0")/api.sh"`

## Request handling

Each accepted connection is delegated to `api.sh`, which is the per-request entry point named in the repository README.

## Operational notes

- The default port documented in the README is `8082`.
- The README describes the server as using standard Unix tools only.
- `nc` is listed as a requirement in the README, while the runtime entry point itself uses `socat`.

## Evidence

- `README.md` documents the server command and default port.
- `server.sh` shows the actual startup and request delegation behavior.
