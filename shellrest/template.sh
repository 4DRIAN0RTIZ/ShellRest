#!/bin/bash

# Minimal Handlebars-like template engine.
#
# Supported tokens, resolved in this strict order (each-blocks -> raw
# scalars -> escaped scalars) so 3-brace tokens are fully consumed before
# the 2-brace pass runs and can't be corrupted by it:
#   {{#each name}}...{{/each}}  loop over a bash array passed by name
#   {{.}} / {{{.}}}             current loop item, escaped / raw
#   {{key}}                     scalar interpolation, HTML-escaped
#   {{{key}}}                   scalar interpolation, raw (trusted fragments only)
#
# Extension points for growing this later without breaking render_view /
# render_partial callers:
#   - each directive type (#each, future #if) is its own _srt_render_*
#     function plugged into the pipeline in _srt_apply.
#   - {{#each}} is not nesting-aware: _srt_render_each matches the first
#     {{/each}} it finds. Nesting support means swapping that search for a
#     balanced open/close counter inside _srt_render_each only.
#   - {{.}} is the whole item string; per-field access ({{.field}}) can be
#     added inside _srt_render_each via a convened separator without
#     touching the public API.

_srt_html_escape() {
    local s="$1"
    # NOTE: bash treats a bare & in the replacement of ${var//pat/repl} as a
    # backreference to the matched text (sed-like), so it must be escaped
    # as \& here or every entity collapses to "<matched-char><entity-name>".
    s="${s//&/\&amp;}"
    s="${s//</\&lt;}"
    s="${s//>/\&gt;}"
    s="${s//\"/\&quot;}"
    s="${s//\'/\&#39;}"
    printf '%s' "$s"
}

# Escapes a value so it is safe to drop into the REPLACEMENT side of a
# ${var//pattern/replacement} expansion. Bash treats a bare backslash or
# ampersand there as an escape/backreference (sed-like) rather than a
# literal character, so any interpolated value (usernames, emails, already
# HTML-escaped strings, etc.) must go through this before substitution or
# arbitrary "&"/"\" in the data corrupts the output.
_srt_escape_repl() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//&/\\&}"
    printf '%s' "$s"
}

_srt_render_each() {
    local template="$1" each_key="$2" array_name="$3"
    local -n items="$array_name"

    local open_tag="{{#each ${each_key}}}"
    local close_tag="{{/each}}"

    while [[ "$template" == *"$open_tag"* ]]; do
        local before="${template%%"$open_tag"*}"
        local after="${template#*"$open_tag"}"

        if [[ "$after" != *"$close_tag"* ]]; then
            debug_log "template.sh: unterminated {{#each ${each_key}}} - leaving as-is"
            break
        fi

        local block="${after%%"$close_tag"*}"
        local remainder="${after#*"$close_tag"}"

        local rendered="" item escaped safe_raw safe_escaped piece
        for item in "${items[@]}"; do
            piece="$block"
            safe_raw=$(_srt_escape_repl "$item")
            piece="${piece//\{\{\{.\}\}\}/$safe_raw}"
            escaped=$(_srt_html_escape "$item")
            safe_escaped=$(_srt_escape_repl "$escaped")
            piece="${piece//\{\{.\}\}/$safe_escaped}"
            rendered+="$piece"
        done

        template="${before}${rendered}${remainder}"
    done

    printf '%s' "$template"
}

_srt_apply() {
    local template="$1"; shift
    local -a pairs=("$@")
    local i key val

    local -A consumed=()

    for (( i=0; i<${#pairs[@]}; i+=2 )); do
        key="${pairs[$i]}"; val="${pairs[$((i+1))]}"
        if [[ "$template" == *"{{#each ${key}}}"* ]]; then
            template=$(_srt_render_each "$template" "$key" "$val")
            consumed["$key"]=1
        fi
    done

    for (( i=0; i<${#pairs[@]}; i+=2 )); do
        key="${pairs[$i]}"; val="${pairs[$((i+1))]}"
        [[ -n "${consumed[$key]:-}" ]] && continue
        local safe_raw
        safe_raw=$(_srt_escape_repl "$val")
        template="${template//\{\{\{$key\}\}\}/$safe_raw}"
    done

    for (( i=0; i<${#pairs[@]}; i+=2 )); do
        key="${pairs[$i]}"; val="${pairs[$((i+1))]}"
        [[ -n "${consumed[$key]:-}" ]] && continue
        local escaped safe_escaped
        escaped=$(_srt_html_escape "$val")
        safe_escaped=$(_srt_escape_repl "$escaped")
        template="${template//\{\{$key\}\}/$safe_escaped}"
    done

    printf '%s' "$template"
}

_srt_read_file() {
    local path="$1"
    if [ ! -f "$path" ]; then
        debug_log "template.sh: file not found: $path"
        printf '<!-- shellrest: template not found: %s -->' "$path"
        return 1
    fi
    cat "$path"
}

render_view() {
    local template_file="$1"; shift
    local views_dir="${VIEWS_DIR:-views}"
    local path="${views_dir%/}/${template_file}"
    local template
    template=$(_srt_read_file "$path") || { printf '%s' "$template"; return 1; }
    _srt_apply "$template" "$@"
}

render_partial() {
    local partial_file="$1"; shift
    local views_dir="${VIEWS_DIR:-views}"
    local path="${views_dir%/}/partials/${partial_file}"
    local template
    template=$(_srt_read_file "$path") || { printf '%s' "$template"; return 1; }
    _srt_apply "$template" "$@"
}
