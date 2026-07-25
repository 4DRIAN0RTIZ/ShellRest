#!/bin/bash

# Registrar rutas
register_route "GET" "/" "get_root"

get_root() {
    http_response "200 OK" "text/plain" "Bienvenido a la API de Bash!"
}