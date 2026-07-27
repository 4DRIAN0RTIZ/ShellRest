#!/bin/bash

# Migration: bashboard
# Created: Mon Jul 27 12:42:17 AM CST 2026

source "$(dirname "$0")/../shellrest/migration.sh"
source "$(dirname "$0")/../shellrest/utils.sh"

up() {
    echo "Running migration: bashboard"

    local columns="$(id_column),
    $(string_column "name"),
    $(timestamps_columns)"
    create_table "skills" "$columns" "$(unique_constraint "name")"

    columns="$(id_column),
    $(string_column "name"),
    $(string_column "description"),
    $(string_column "url"),
    $(string_column "url_github"),
    $(string_column "skills"),
    $(timestamps_columns)"
    create_table "projects" "$columns"

    columns="$(id_column),
    $(string_column "title"),
    $(string_column "subtitle"),
    $(string_column "issuer"),
    $(string_column "year"),
    $(timestamps_columns)"
    create_table "certifications" "$columns"

    columns="$(id_column),
    $(string_column "title"),
    $(string_column "field"),
    $(string_column "institution"),
    $(string_column "year"),
    $(timestamps_columns)"
    create_table "degrees" "$columns"

    local skill
    for skill in "HTML" "JavaScript" "CSS" "Laravel" "Markdown" "Git" "PHP" "Python" "Terminal" "React"; do
        execute_query "INSERT OR IGNORE INTO skills (name) VALUES ($(safe_sql_string "$skill"));"
    done

    _seed_project() {
        local name="$1" description="$2" url="$3" url_github="$4" skills="$5"
        execute_query "INSERT INTO projects (name, description, url, url_github, skills) VALUES (
            $(safe_sql_string "$name"),
            $(safe_sql_string "$description"),
            $(safe_sql_string "$url"),
            $(safe_sql_string "$url_github"),
            $(safe_sql_string "$skills")
        );"
    }

    _seed_project "PlanetsView" \
        "Aplicación web que muestra información sobre los planetas del sistema solar utilizando HTML, CSS y JavaScript." \
        "https://planetsview.cuevaneander.tech" "https://github.com/4drian0rtiz/" "HTML,JavaScript"

    _seed_project "HeroQuiz" \
        "Juego de preguntas y respuestas sobre superhéroes utilizando HTML, CSS y JavaScript." \
        "https://heroquiz.cuevaneander.tech" "https://github.com/4drian0rtiz/" "HTML,Python"

    _seed_project "Flintbox" \
        "Laboratorio self-hosted que ejecuta binarios reales de jq, awk, sed, grep y cut en un contenedor aislado, accesible desde el navegador." \
        "https://flintbox.neanderhub.com" "https://cuevaneander.tech/blog/flintbox-mi-laboratorio-selfhosted/" "HTML,Terminal"

    _seed_project "CrystalAlert" \
        "Biblioteca ligera de alertas y notificaciones con diseño glassmorphism" \
        "https://crystalert.cuevaneander.tech" "https://github.com/4drian0rtiz/CrystalAlert" "JavaScript,CSS"

    _seed_project "UrbanTV" \
        "Plataforma para votaciones de batallas de freestyle." \
        "https://miproyectoapi.com" "https://github.com/miusuario/miproyectoapi" "Laravel"

    _seed_project "Documentación en GitHub" \
        "Contribuciones a repositorios en GitHub usando Markdown para documentación." \
        "https://github.com/pulls?q=is:pr+author:4drian0rtiz" "https://github.com/pulls?q=is:pr+author:4drian0rtiz" "Markdown"

    _seed_project "Colaboración en GitHub" \
        "Proyectos colaborativos y contribuciones a repositorios de código abierto." \
        "https://ghcard.cuevaneander.tech/?username=4drian0rtiz&theme=TokyoNight&per_page=50" \
        "https://github.com/pulls?q=is:pr+author:4drian0rtiz" "Git"

    _seed_project "Proyecto Portafolio" \
        "Un portafolio web personal con secciones sobre mí, proyectos y contacto." \
        "https://developer.cuevaneander.tech" "https://github.com/4drian0rtiz/4drian0rtiz.github.io" "PHP,React"

    _seed_project "Un dia como hoy" \
        "Una aplicación que muestra eventos históricos del día actual utilizando una API construida con web scraping." \
        "https://un-dia-como-hoy.onrender.com" "https://github.com/4drian0rtiz/UnDiaComoHoy" "Python"

    _seed_project "AnsibleScout" \
        "Herramienta con TUI para buscar documentación de módulos de Ansible." \
        "https://ascout.cuevaneander.tech" "https://github.com/4drian0rtiz/" "Python"

    _seed_project "AgoraCLI" \
        "Herramienta no oficial de la plataforma de la Universidad Tecnológica de Jalisco (UTJ) para gestionar horarios y referencias bancarias de los estudiantes." \
        "https://cuevaneander.tech/blog/agoracli-consulta-calificaciones-desde-la-terminal" "https://github.com/4drian0rtiz/agoracli" "Python"

    _seed_project "DateIcon" \
        "REST API para crear iconos de calendario personalizados." \
        "https://dateicon.cuevaneander.tech/" "https://github.com/4drian0rtiz/dateicon" "Python"

    _seed_project "NeoComposer" \
        "Herramienta de línea de comandos para envio de correos electrónicos masivos utilizando plantillas personalizadas." \
        "https://neocomposer.cuevaneander.tech" "https://github.com/4drian0rtiz/neocomposer" "Terminal"

    _seed_project "ShellRest" \
        "Framework pure shell para crear APIs RESTful utilizando solo bash y herramientas de línea de comandos." \
        "https://shellrest.cuevaneander.tech" "https://github.com/4drian0rtiz/shellrest" "Terminal"

    _seed_project "La Cueva del NeanderTech" \
        "Blog personal sobre desarrollo web y tecnología." \
        "https://cuevaneander.tech" "https://github.com/4drian0rtiz/" "React"

    _seed_project "Códice" \
        "Aplicación web para la gestión y organización de notas y documentos personales." \
        "https://codice.cuevaneander.tech" "https://github.com/4drian0rtiz/" "React"

    _seed_project "CvCraft" \
        "Aplicación web para crear currículums personalizados y descargarlos en formato PDF." \
        "https://cvcraft.cuevaneander.tech" "https://github.com/4drian0rtiz/cvcraft" "React"

    _seed_project "GHCard" \
        "Genera una tarjeta SVG dinámicamente que muestra tus contribuciones de PR en GitHub." \
        "https://ghcard.cuevaneander.tech" "https://github.com/4drian0rtiz/github-contributions-card" "React"

    _seed_cert() {
        local title="$1" subtitle="$2" issuer="$3" year="$4"
        execute_query "INSERT INTO certifications (title, subtitle, issuer, year) VALUES (
            $(safe_sql_string "$title"), $(safe_sql_string "$subtitle"),
            $(safe_sql_string "$issuer"), $(safe_sql_string "$year")
        );"
    }

    _seed_cert "AI Essentials Google" "Coursera" "Coursera" "2025"
    _seed_cert "Security Operations Fundamentals" "PaloAlto" "PaloAlto" "2025"
    _seed_cert "Introduction to Cybersecurity" "NETACAD" "NETACAD" "2024"
    _seed_cert "ICP Developer" "Zona_Tres" "Zona_Tres" "2025"
    _seed_cert "ICP Developer" "ICP México" "ICP México" "2025"
    _seed_cert "Cybersecurity Essentials" "NETACAD" "NETACAD" "2022"
    _seed_cert "Curso profesional de React" "codigo_facilito" "codigo_facilito" "2025"
    _seed_cert "Curso profesional de JavaScript" "codigo_facilito" "codigo_facilito" "2023"
    _seed_cert "Clase de introducción a R" "codigo_facilito" "codigo_facilito" "2023"
    _seed_cert "Desarrollo de Lideres" "fortane" "fortane" "2026"
    _seed_cert "White Belt" "en-trega" "en-trega" "2024"

    _seed_degree() {
        local title="$1" field="$2" institution="$3" year="$4"
        execute_query "INSERT INTO degrees (title, field, institution, year) VALUES (
            $(safe_sql_string "$title"), $(safe_sql_string "$field"),
            $(safe_sql_string "$institution"), $(safe_sql_string "$year")
        );"
    }

    _seed_degree "Técnico Superior Universitario" "Desarrollo de Software Multiplataforma" "Universidad Tecnológica de Jalisco" "2021 - 2023"
    _seed_degree "Ingeniería" "Gestión y Desarrollo de Software" "Universidad Tecnológica de Jalisco" "2023 - 2025"
}

down() {
    echo "Rolling back migration: bashboard"

    drop_table "degrees"
    drop_table "certifications"
    drop_table "projects"
    drop_table "skills"
}

if [ "$1" = "up" ]; then
    up
elif [ "$1" = "down" ]; then
    down
else
    echo "Usage: $0 {up|down}"
    exit 1
fi
