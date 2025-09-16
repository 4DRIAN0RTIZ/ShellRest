#!/bin/bash

source "$(dirname "$0")/framework/config.sh"
source "$(dirname "$0")/framework/http.sh"
source "$(dirname "$0")/framework/router.sh"
source "$(dirname "$0")/framework/database.sh"
source "$(dirname "$0")/framework/middleware.sh"
source "$(dirname "$0")/framework/validation.sh"
source "$(dirname "$0")/framework/utils.sh"

load_config
init_database
load_routes "routes"

add_middleware "logging_middleware"
add_middleware "cors_middleware"


# Leer la primera línea (línea de petición)
IFS= read -r request_line
request_line=${request_line%$'\r'}

# Leer los headers hasta línea vacía
request_headers=""
while IFS= read -r line; do
    line=${line%$'\r'}
    if [ -z "$line" ]; then
        break
    fi
    request_headers="$request_headers\n$line"
done

# Extraer método y ruta
REQUEST_METHOD=$(echo "$request_line" | awk '{print $1}')
REQUEST_PATH=$(echo "$request_line" | awk '{print $2}')

# Normalizar ruta: remover barra final excepto para ruta raíz
if [ "$REQUEST_PATH" != "/" ]; then
    REQUEST_PATH=${REQUEST_PATH%/}
fi

# Debug: escribir a log para ver qué recibe
echo "DEBUG: request_line='$request_line'" >> debug.log
echo "DEBUG: METHOD='$REQUEST_METHOD' PATH='$REQUEST_PATH'" >> debug.log

# Separar query string si existe
if [[ "$REQUEST_PATH" == *"?"* ]]; then
    QUERY_STRING="${REQUEST_PATH#*?}"
    REQUEST_PATH="${REQUEST_PATH%%?*}"
fi

# Leer el cuerpo de la petición si existe
body=""
if [[ "$REQUEST_METHOD" == "POST" ]] || [[ "$REQUEST_METHOD" == "PUT" ]] || [[ "$REQUEST_METHOD" == "PATCH" ]]; then
    content_length=$(echo -e "$request_headers" | grep -i "content-length" | awk -F': ' '{print $2}' | tr -d '\r')
    echo "DEBUG: content_length='$content_length'" >> debug.log
    if [ -n "$content_length" ] && [ "$content_length" -gt 0 ]; then
        body=$(dd bs=1 count="$content_length" 2>/dev/null)
        echo "DEBUG: body='$body'" >> debug.log
    fi
fi

if run_middleware "$REQUEST_METHOD" "$REQUEST_PATH" "$body"; then
    route_request "$REQUEST_METHOD" "$REQUEST_PATH" "$body"
fi
# Flush output to ensure complete transmission
exec 1>&-
