#!/bin/bash

source "$(dirname "$0")/shellrest/config.sh"

load_config

PORT=$(get_config "port")

echo "Servidor escuchando en http://localhost:${PORT}"
echo "Presiona Ctrl+C para detener."

socat TCP-LISTEN:${PORT},fork,reuseaddr EXEC:"$(dirname "$0")/api.sh"
