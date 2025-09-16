#!/bin/bash

source "$(dirname "$0")/framework/config.sh"

load_config

# Puerto en el que escuchará el servidor
PORT=$(get_config "port")

# Crear un pipe con nombre (FIFO) para la comunicación bidireccional
PIPE=$(mktemp -u)
mkfifo "$PIPE"
trap 'rm -f "$PIPE"' EXIT # Limpiar el pipe al salir

echo "Servidor escuchando en http://localhost:${PORT}"
echo "Presiona Ctrl+C para detener."

# Bucle infinito para mantener el servidor escuchando
while true; do
    # nc escucha, su salida (la petición) va a api.sh
    # la salida de api.sh (la respuesta) va al pipe
    # nc lee la respuesta del pipe y la envía al cliente
    nc -l -p ${PORT} < "$PIPE" | ./api.sh > "$PIPE"
done