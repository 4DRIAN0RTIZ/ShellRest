#!/bin/bash

# route:list command library — used by bin/shellrest

_print_route_table() {
    local -i method_w=6 path_w=6 handler_w=7
    local route_key method path handler

    for route_key in "${REGISTERED_ROUTES[@]}"; do
        method="${route_key%% *}"
        path="${route_key#* }"
        handler="${ROUTE_HANDLERS[$route_key]}"
        (( ${#method} > method_w )) && method_w=${#method}
        (( ${#path} > path_w )) && path_w=${#path}
        (( ${#handler} > handler_w )) && handler_w=${#handler}
    done

    printf '%-*s  %-*s  %-*s\n' "$method_w" "METHOD" "$path_w" "PATH" "$handler_w" "HANDLER"
    printf '%s\n' "$(printf '%*s' "$((method_w + path_w + handler_w + 4))" '' | tr ' ' '-')"

    for route_key in "${REGISTERED_ROUTES[@]}"; do
        method="${route_key%% *}"
        path="${route_key#* }"
        handler="${ROUTE_HANDLERS[$route_key]}"
        printf '%-*s  %-*s  %-*s\n' "$method_w" "$method" "$path_w" "$path" "$handler_w" "$handler"
    done
}

cmd_route_list() {
    source "${_PROJECT_ROOT}/shellrest/config.sh"
    source "${_PROJECT_ROOT}/shellrest/http.sh"
    source "${_PROJECT_ROOT}/shellrest/router.sh"
    source "${_PROJECT_ROOT}/shellrest/database.sh"
    source "${_PROJECT_ROOT}/shellrest/middleware.sh"
    source "${_PROJECT_ROOT}/shellrest/validation.sh"
    source "${_PROJECT_ROOT}/shellrest/utils.sh"
    source "${_PROJECT_ROOT}/shellrest/template.sh"

    load_config
    init_database
    load_routes "${_PROJECT_ROOT}/routes"

    if [ "${#REGISTERED_ROUTES[@]}" -eq 0 ]; then
        echo "No routes registered."
        return 0
    fi

    _print_route_table
    echo ""
    printf '%d routes (matched top-to-bottom in this order)\n' "${#REGISTERED_ROUTES[@]}"
}
