#!/bin/bash

register_route "GET" "/"               "get_dashboard"
register_route "GET" "/projects"       "get_projects_view"
register_route "GET" "/skills"         "get_skills_view"
register_route "GET" "/certifications" "get_certifications_view"

_bashboard_skill_counts_json() {
    db_raw_query "SELECT s.name AS name,
        (SELECT COUNT(*) FROM projects p WHERE (','||p.skills||',') LIKE '%,'||s.name||',%') AS count
        FROM skills s ORDER BY count DESC, s.name ASC" json
}

_bashboard_skill_bars() {
    local json="$1"
    local -n _out="$2"
    local count max=1 i name c percent
    count=$(printf '%s' "$json" | jq 'length')
    max=$(printf '%s' "$json" | jq '[.[].count] | max // 1')
    [ "$max" -lt 1 ] && max=1
    for (( i=0; i<count; i++ )); do
        name=$(printf '%s' "$json" | jq -r ".[$i].name")
        c=$(printf '%s' "$json" | jq -r ".[$i].count")
        percent=$(( c * 100 / max ))
        _out+=("$(render_partial "skill_bar.html" "name" "$name" "count" "$c" "percent" "$percent")")
    done
}

_bashboard_project_card() {
    local id="$1" name="$2" description="$3" url="$4" url_github="$5" skills_csv="$6"
    local badges="" links="" IFS=',' skill
    for skill in $skills_csv; do
        [ -z "$skill" ] && continue
        badges="${badges}<span class=\"badge\">$(_srt_html_escape "$skill")</span>"
    done
    [ -n "$url" ] && links="${links}<a href=\"$(_srt_html_escape "$url")\" target=\"_blank\" rel=\"noopener\">Live</a>"
    [ -n "$url_github" ] && links="${links}<a href=\"$(_srt_html_escape "$url_github")\" target=\"_blank\" rel=\"noopener\">Code</a>"
    render_partial "project_card.html" \
        "name" "$name" "description" "$description" "badges" "$badges" "links" "$links"
}

get_dashboard() {
    local total_projects total_skills total_certs total_degrees
    total_projects=$(db_count "projects")
    total_skills=$(db_count "skills")
    total_certs=$(db_count "certifications")
    total_degrees=$(db_count "degrees")

    local skills_json
    skills_json=$(_bashboard_skill_counts_json)
    [ -z "$skills_json" ] && skills_json="[]"

    local top_skill_name top_skill_count
    top_skill_name=$(printf '%s' "$skills_json" | jq -r '.[0].name // "-"')
    top_skill_count=$(printf '%s' "$skills_json" | jq -r '.[0].count // 0')

    local -a skill_bars=()
    _bashboard_skill_bars "$skills_json" skill_bars

    local projects_json
    projects_json=$(db_raw_query "SELECT id, name, description, url, url_github, skills FROM projects ORDER BY id DESC LIMIT 5")
    [ -z "$projects_json" ] && projects_json="[]"

    local -a project_cards=()
    local pcount i pid pname pdesc purl pgh pskills
    pcount=$(printf '%s' "$projects_json" | jq 'length')
    for (( i=0; i<pcount; i++ )); do
        pid=$(printf '%s' "$projects_json" | jq -r ".[$i].id")
        pname=$(printf '%s' "$projects_json" | jq -r ".[$i].name")
        pdesc=$(printf '%s' "$projects_json" | jq -r ".[$i].description // \"\"")
        purl=$(printf '%s' "$projects_json" | jq -r ".[$i].url // \"\"")
        pgh=$(printf '%s' "$projects_json" | jq -r ".[$i].url_github // \"\"")
        pskills=$(printf '%s' "$projects_json" | jq -r ".[$i].skills // \"\"")
        project_cards+=("$(_bashboard_project_card "$pid" "$pname" "$pdesc" "$purl" "$pgh" "$pskills")")
    done

    local head_html nav_html
    head_html=$(render_partial "layout_head.html")
    nav_html=$(render_partial "nav.html")

    local body
    body=$(render_view "dashboard.html" \
        "head" "$head_html" "nav" "$nav_html" \
        "total_projects" "$total_projects" "total_skills" "$total_skills" \
        "total_certifications" "$total_certs" "total_degrees" "$total_degrees" \
        "top_skill_name" "$top_skill_name" "top_skill_count" "$top_skill_count" \
        "skill_bars" "skill_bars" "project_cards" "project_cards")
    http_response "200 OK" "text/html" "$body"
}

get_projects_view() {
    local projects_json
    projects_json=$(db_select "projects" "id, name, description, url, url_github, skills" "" "json")
    [ -z "$projects_json" ] && projects_json="[]"

    local count i pid pname pdesc purl pgh pskills
    count=$(printf '%s' "$projects_json" | jq 'length')

    local -a project_cards=()
    for (( i=0; i<count; i++ )); do
        pid=$(printf '%s' "$projects_json" | jq -r ".[$i].id")
        pname=$(printf '%s' "$projects_json" | jq -r ".[$i].name")
        pdesc=$(printf '%s' "$projects_json" | jq -r ".[$i].description // \"\"")
        purl=$(printf '%s' "$projects_json" | jq -r ".[$i].url // \"\"")
        pgh=$(printf '%s' "$projects_json" | jq -r ".[$i].url_github // \"\"")
        pskills=$(printf '%s' "$projects_json" | jq -r ".[$i].skills // \"\"")
        project_cards+=("$(_bashboard_project_card "$pid" "$pname" "$pdesc" "$purl" "$pgh" "$pskills")")
    done

    local head_html nav_html
    head_html=$(render_partial "layout_head.html")
    nav_html=$(render_partial "nav.html")

    local body
    body=$(render_view "projects.html" \
        "head" "$head_html" "nav" "$nav_html" \
        "count" "$count" "project_cards" "project_cards")
    http_response "200 OK" "text/html" "$body"
}

get_skills_view() {
    local skills_json
    skills_json=$(_bashboard_skill_counts_json)
    [ -z "$skills_json" ] && skills_json="[]"

    local count
    count=$(printf '%s' "$skills_json" | jq 'length')

    local -a skill_bars=()
    _bashboard_skill_bars "$skills_json" skill_bars

    local head_html nav_html
    head_html=$(render_partial "layout_head.html")
    nav_html=$(render_partial "nav.html")

    local body
    body=$(render_view "skills.html" \
        "head" "$head_html" "nav" "$nav_html" \
        "count" "$count" "skill_bars" "skill_bars")
    http_response "200 OK" "text/html" "$body"
}

get_certifications_view() {
    local certs_json degrees_json
    certs_json=$(db_select "certifications" "id, title, subtitle, issuer, year" "" "json")
    [ -z "$certs_json" ] && certs_json="[]"
    degrees_json=$(db_select "degrees" "id, title, field, institution, year" "" "json")
    [ -z "$degrees_json" ] && degrees_json="[]"

    local cert_count degree_count i title subtitle issuer year field institution
    cert_count=$(printf '%s' "$certs_json" | jq 'length')
    degree_count=$(printf '%s' "$degrees_json" | jq 'length')

    local -a cert_rows=() degree_rows=()
    for (( i=0; i<cert_count; i++ )); do
        title=$(printf '%s' "$certs_json" | jq -r ".[$i].title")
        subtitle=$(printf '%s' "$certs_json" | jq -r ".[$i].subtitle // \"\"")
        issuer=$(printf '%s' "$certs_json" | jq -r ".[$i].issuer // \"\"")
        year=$(printf '%s' "$certs_json" | jq -r ".[$i].year // \"\"")
        cert_rows+=("$(render_partial "cert_row.html" \
            "title" "$title" "subtitle" "$subtitle" "issuer" "$issuer" "year" "$year")")
    done
    for (( i=0; i<degree_count; i++ )); do
        title=$(printf '%s' "$degrees_json" | jq -r ".[$i].title")
        field=$(printf '%s' "$degrees_json" | jq -r ".[$i].field // \"\"")
        institution=$(printf '%s' "$degrees_json" | jq -r ".[$i].institution // \"\"")
        year=$(printf '%s' "$degrees_json" | jq -r ".[$i].year // \"\"")
        degree_rows+=("$(render_partial "degree_row.html" \
            "title" "$title" "field" "$field" "institution" "$institution" "year" "$year")")
    done

    local head_html nav_html
    head_html=$(render_partial "layout_head.html")
    nav_html=$(render_partial "nav.html")

    local body
    body=$(render_view "certifications.html" \
        "head" "$head_html" "nav" "$nav_html" \
        "cert_count" "$cert_count" "degree_count" "$degree_count" \
        "cert_rows" "cert_rows" "degree_rows" "degree_rows")
    http_response "200 OK" "text/html" "$body"
}
