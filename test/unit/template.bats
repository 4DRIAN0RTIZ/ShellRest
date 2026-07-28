#!/usr/bin/env bats

setup() {
    load '../test_helper/common_setup'
    _common_setup
    source "$PROJECT_ROOT/shellrest/config.sh"
    source "$PROJECT_ROOT/shellrest/template.sh"

    VIEWS_DIR="$(mktemp -d "${BATS_TMPDIR:-/tmp}/shellrest-views-XXXXXX")"
    export VIEWS_DIR
    mkdir -p "$VIEWS_DIR/partials"
}

teardown() {
    rm -rf "$VIEWS_DIR"
    _common_teardown
}

@test "render_view interpolates and HTML-escapes a scalar" {
    printf '<p>{{name}}</p>' > "$VIEWS_DIR/greet.html"
    run render_view "greet.html" name '<b>Bob</b>'
    assert_success
    assert_output '<p>&lt;b&gt;Bob&lt;/b&gt;</p>'
}

@test "render_view renders triple-brace token raw" {
    printf '<div>{{{body}}}</div>' > "$VIEWS_DIR/raw.html"
    run render_view "raw.html" body '<b>ok</b>'
    assert_success
    assert_output '<div><b>ok</b></div>'
}

@test "render_view expands #each over an array, escaping items" {
    printf '<ul>{{#each items}}<li>{{.}}</li>{{/each}}</ul>' > "$VIEWS_DIR/list.html"
    list_items=('one' '<x>')
    run render_view "list.html" items list_items
    assert_success
    assert_output '<ul><li>one</li><li>&lt;x&gt;</li></ul>'
}

@test "render_view reports missing template file" {
    run render_view "missing.html"
    assert_failure
    assert_output --partial 'template not found'
}

@test "render_partial resolves under views_dir/partials" {
    printf '<span>{{label}}</span>' > "$VIEWS_DIR/partials/tag.html"
    run render_partial "tag.html" label "ok"
    assert_success
    assert_output '<span>ok</span>'
}
