#!/bin/bash

declare -a REGISTERED_ROUTES
declare -A ROUTE_HANDLERS
declare -A ROUTE_PATTERNS

register_route() {
    local method="$1"
    local pattern="$2"
    local handler="$3"
    local route_key="${method} ${pattern}"

    REGISTERED_ROUTES+=("$route_key")
    ROUTE_HANDLERS["$route_key"]="$handler"
    ROUTE_PATTERNS["$route_key"]="$pattern"
}

load_routes() {
    local routes_dir="${1:-routes}"

    if [ ! -d "$routes_dir" ]; then
        printf 'Error: routes directory "%s" not found\n' "$routes_dir" >&2
        return 1
    fi

    local route_file
    for route_file in "$routes_dir"/*.sh; do
        [ -f "$route_file" ] && source "$route_file"
    done
}

_split_path() {
    local path="$1"
    local -n _out="$2"
    local IFS='/'
    read -ra _out <<< "$path"
}

match_route_pattern() {
    local pattern="$1"
    local path="$2"

    local -a pseg pseg_p
    _split_path "$pattern" pseg_p
    _split_path "$path"    pseg

    [[ ${#pseg_p[@]} -ne ${#pseg[@]} ]] && return 1

    local i
    for i in "${!pseg_p[@]}"; do
        local seg="${pseg_p[$i]}"
        [[ "$seg" =~ ^\{.*\}$ || "$seg" == "*" ]] && continue
        [[ "$seg" != "${pseg[$i]}" ]] && return 1
    done

    return 0
}

extract_path_params() {
    local pattern="$1"
    local path="$2"

    declare -g -A PATH_PARAMS=()

    local -a pseg pseg_p
    _split_path "$pattern" pseg_p
    _split_path "$path"    pseg

    local i
    for i in "${!pseg_p[@]}"; do
        local seg="${pseg_p[$i]}"
        if [[ "$seg" =~ ^\{.*\}$ ]]; then
            local param="${seg#\{}"
            param="${param%\}}"
            PATH_PARAMS["$param"]="${pseg[$i]}"
        fi
    done
}

route_request() {
    local method="$1"
    local path="$2"
    local body="$3"

    local exact_key="${method} ${path}"
    if [[ -n "${ROUTE_HANDLERS[$exact_key]:-}" ]]; then
        local handler="${ROUTE_HANDLERS[$exact_key]}"
        declare -f "$handler" > /dev/null 2>&1 && { "$handler" "$body"; return 0; }
    fi

    local route_key route_method route_pattern handler
    for route_key in "${REGISTERED_ROUTES[@]}"; do
        route_method="${route_key%% *}"
        route_pattern="${route_key#* }"

        [[ "$method" != "$route_method" ]] && continue
        match_route_pattern "$route_pattern" "$path" || continue

        handler="${ROUTE_HANDLERS[$route_key]}"
        declare -f "$handler" > /dev/null 2>&1 || continue

        extract_path_params "$route_pattern" "$path"

        if [[ "$route_pattern" =~ \{.*\} ]]; then
            local params=() seg param
            local -a pseg_p
            _split_path "$route_pattern" pseg_p
            for seg in "${pseg_p[@]}"; do
                if [[ "$seg" =~ ^\{.*\}$ ]]; then
                    param="${seg#\{}"
                    param="${param%\}}"
                    params+=("${PATH_PARAMS[$param]}")
                fi
            done
            "$handler" "${params[@]}" "$body"
        else
            "$handler" "$body"
        fi
        return 0
    done

    http_response "404 Not Found" "application/json" '{"error":"Route not found"}'
}
