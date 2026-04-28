// ── TRANSLATIONS ─────────────────────────────────────────────────────────
const TRANSLATIONS = {
  en: {
    // Hero
    'hero.tagline': 'Pure Bash REST API Framework',
    'hero.desc': 'ShellRest is an HTTP framework written entirely in Bash 5+. No runtime dependencies — just <code>bash</code>, <code>sqlite3</code>, <code>jq</code> and <code>nc</code>. Router with path params, ORM-like helpers, migration system, middleware pipeline.',

    // 01 Overview
    'overview.p1': 'ShellRest turns a Bash script into a functional HTTP server. Each request spawns a child process that sources the framework, matches the route, executes the handler and returns a complete HTTP/1.1 response.',
    'overview.stack-title': '<strong style="color:var(--text-bright)">Minimum required stack:</strong>',
    'overview.flow-title': '<strong style="color:var(--text-bright)">Request flow:</strong>',
    'overview.callout': 'Each request is an independent Bash process. No shared state between requests — all state persists in SQLite.',
    'pipeline.nc': 'nc (accepts TCP)',

    // 02 Quick Start
    'qs.h3-clone': 'Clone and initialize',
    'qs.h3-first': 'First request',
    'qs.h3-route': 'Create a new route in 60 seconds',
    'qs.callout': 'ShellRest automatically loads all <code>*.sh</code> files inside <code>routes/</code>. No need to register the file.',

    // 03 Project Structure
    'tree.server': '# TCP server — starts nc in a loop',
    'tree.api': '# Entry point per request — parses HTTP, runs pipeline',
    'tree.migrate': '# Migration runner',
    'tree.make-migration': '# Migration file generator',
    'tree.env': '# Environment variables (optional)',
    'tree.shellrest': '# Framework core',
    'tree.config': '# load_config, get_config, debug_log',
    'tree.http': '# http_response, parse_query_string, get_header',
    'tree.router': '# register_route, route_request, match_route_pattern',
    'tree.database': '# execute_query, escape_sql',
    'tree.middleware': '# add_middleware, run_middleware, built-in middlewares',
    'tree.migration': '# Schema builder + migration tracking',
    'tree.utils': '# db_select/insert/update/delete/join, json_error',
    'tree.validation': '# validate_json, validate_email, validate_integer…',
    'tree.routes': '# Route handlers (auto-loaded)',
    'tree.migrations-dir': '# Migration files (ordered by timestamp)',

    // 04 Configuration
    'config.p1': 'ShellRest reads configuration from <code>.env</code> in the project root. All variables are optional — if they don\'t exist, defaults are used.',
    'config.th1': 'Variable',
    'config.th2': 'Default',
    'config.th3': 'Description',
    'config.api-port-desc': 'TCP port where the server listens',
    'config.api-host-desc': 'Server host',
    'config.db-file-desc': 'Path to the SQLite file. Relative to project root',
    'config.log-file-desc': 'Path to the access log written by <code>logging_middleware</code>',
    'config.debug-desc': 'Enables <code>debug_log()</code> — writes to stderr',
    'config.cors-origin-desc': 'Value of the <code>Access-Control-Allow-Origin</code> header',
    'config.cors-methods-desc': 'HTTP methods allowed by CORS',
    'config.cors-headers-desc': 'Headers allowed by CORS',
    'config.h3-api': 'Configuration API',
    'config.load-config-desc': 'Loads the <code>.env</code> file and exports all variables with their defaults. Called automatically in <code>api.sh</code> and <code>server.sh</code>.',
    'config.get-config-desc': 'Returns the value of a configuration key by name.',
    'config.param-th2': 'Type',
    'config.param-th3': 'Valid values',
    'config.debug-log-desc': 'Writes to stderr only when <code>DEBUG=true</code>. No effect in production.',

    // 05 Routing
    'routing.p1': 'The router uses Bash associative arrays to map <code>METHOD PATH</code> → handler function. Supports exact routes and routes with path parameters (<code>{param}</code>).',
    'routing.h3-params': 'Path Parameters',
    'routing.params-p': 'Segments in curly braces <code>{name}</code> in the pattern are automatically extracted and passed to the handler as positional arguments in the order they appear in the path.',
    'routing.h3-query': 'Query String',
    'routing.query-p': 'Query params are parsed with <code>parse_query_string</code> and exported as variables with prefix <code>QUERY_</code>.',
    'routing.callout': 'The global array <code>PATH_PARAMS</code> is also available: <code>${PATH_PARAMS["id"]}</code>. Positional args are more convenient for most cases.',
    'routing.register-desc': 'Registers a route associating an HTTP method and path pattern with a Bash function.',
    'routing.th-type': 'Type',
    'routing.th-desc': 'Description',
    'routing.pattern-desc': 'Path with support for <code>{param}</code> and wildcard <code>*</code>',
    'routing.handler-desc': 'Name of the Bash function that handles the request',
    'routing.get-header-desc': 'Looks up an HTTP header by name (case-insensitive) in the current request. Returns empty if it doesn\'t exist.',
    'routing.load-routes-desc': 'Sources all <code>*.sh</code> files in the specified directory. Called automatically in <code>api.sh</code>. Each file can register as many routes as it wants.',

    // 06 HTTP Responses
    'http.response-desc': 'Writes a complete HTTP/1.1 response to stdout, including automatic CORS headers and calculated <code>Content-Length</code>.',
    'http.th-examples': 'Examples',
    'http.h3-helpers': 'Response helpers',
    'http.json-error-desc': 'Returns a standard error JSON: <code>{"error":"message"}</code>',
    'http.json-success-desc': 'Returns a standard success JSON: <code>{"message":"..."}</code>',
    'http.h3-cors': 'CORS Headers',
    'http.cors-p': 'All CORS headers are automatically injected on every <code>http_response</code> call. Controlled from <code>.env</code>:',

    // 07 Database
    'db.p1': 'ShellRest uses SQLite via CLI (<code>sqlite3</code>). The <code>utils.sh</code> module provides high-level helpers over <code>execute_query</code>. Everything returns JSON by default.',
    'db.h3-basic': 'Basic queries',
    'db.h3-count': 'Count and existence',
    'db.h3-utils': 'DB utilities',
    'db.select-desc': 'Executes a SELECT and returns the result. JSON format by default.',
    'db.th-desc': 'Description',
    'db.param-table': 'Table name',
    'db.param-fields': 'Columns to select',
    'db.param-where': 'WHERE clause (without the WHERE keyword)',
    'db.param-format': 'Output format',
    'db.insert-desc': 'Executes an INSERT. Use <code>safe_sql_string()</code> to escape text values.',
    'db.update-desc': 'Executes an UPDATE. Check <code>db_get_changes()</code> to know if any rows were affected.',
    'db.delete-desc': 'Executes a DELETE. Check <code>db_get_changes()</code> to confirm something was deleted.',
    'db.count-desc': 'Returns the number of rows that match the condition.',
    'db.exists-desc': 'Returns 0 (true) if at least one row matches the condition, 1 (false) if not.',
    'db.inner-join-desc': 'INNER JOIN between two tables.',
    'db.left-join-desc': 'LEFT JOIN between two tables. Includes rows from <code>table1</code> without a match in <code>table2</code>.',
    'db.multi-join-desc': 'Multiple JOIN with full support for GROUP BY, HAVING, ORDER BY and LIMIT.',
    'db.aggregate-desc': 'Aggregation queries — SUM, COUNT, AVG, MIN, MAX with GROUP BY and HAVING.',
    'db.execute-desc': 'Executes arbitrary SQL against the database. Returns the result in the specified format.',
    'db.safe-sql-desc': 'Escapes single quotes and wraps the value in SQL quotes. <strong>Always use for text values in queries.</strong>',
    'db.callout': 'Never interpolate variables directly into queries without <code>safe_sql_string()</code>. Numeric values validated with <code>validate_integer()</code> are the only safe exception.',

    // 08 Validation
    'val.p1': 'Validation module for user inputs. All functions return 0 (success) or 1 (failure) for direct use in conditionals.',
    'val.required-desc': 'Verifies that all specified fields exist and are not null in the received JSON.',
    'val.email-desc': 'Validates email format with regex. Does not verify domain existence.',
    'val.integer-desc': 'Verifies that the value is a positive integer (<code>[0-9]+</code>). Useful for IDs before using them in queries.',
    'val.path-param-desc': 'Validates that a path param is an integer. If it fails, automatically writes a <code>400</code> and returns 1. Standard pattern in all handlers with <code>{id}</code>.',
    'val.json-desc': 'Verifies that the string is valid JSON using <code>jq empty</code>.',
    'val.sanitize-desc': 'Removes non-printable control characters (<code>\\x00-\\x1F</code> and <code>\\x7F</code>) from input.',

    // 09 Middleware
    'mw.p1': 'The middleware pipeline runs <em>before</em> the request reaches the route handler. If a middleware returns 1 (failure), the pipeline stops and the handler is not called.',
    'mw.add-desc': 'Adds a function to the pipeline. Call order reflects registration order.',
    'mw.h3-builtin': 'Built-in middlewares',
    'mw.logging-p': 'Writes each request to <code>$LOG_FILE</code> with timestamp, method and path.',
    'mw.cors-p': 'Intercepts <code>OPTIONS</code> requests (preflight) and responds with <code>204 No Content</code> with CORS headers. For other methods, returns 0 and lets the request through.',
    'mw.auth-p': 'Included example: protects routes under <code>/protected/*</code>. Verifies that the <code>Authorization</code> header is present; if not, responds with <code>401</code>.',
    'mw.h3-custom': 'Custom middleware',
    'mw.custom-p': 'A middleware is any Bash function that receives <code>(method, path, body)</code> and returns 0 to continue or 1 to stop the pipeline.',
    'mw.pipe-request': 'Request',
    'mw.pipe-auth': 'auth_middleware (opt)',

    // 10 Migrations
    'mg.p1': 'The migration system tracks which scripts have already been executed in the SQLite <code>migrations</code> table. Each migration has <code>up()</code> and <code>down()</code> functions.',
    'mg.h3-commands': 'migrate.sh commands',
    'mg.h3-create': 'Create a migration',
    'mg.create-p': 'The script generates a timestamped file in <code>migrations/</code> ready to edit:',

    // 11 Schema Builder
    'schema.p1': 'Helpers that generate DDL SQL fragments. Used inside migration <code>up()</code> functions.',
    'schema.h3-constraints': 'Constraints and Indexes',
    'schema.th-fn': 'Function',
    'schema.th-sql': 'Generated SQL',
    'schema.th-sig': 'Signature',
    'schema.no-params': 'no parameters',
    'schema.timestamps-desc': 'no parameters — adds both',
    'schema.datetime-desc': '(name, default="", nullable=true) — use "now" for CURRENT_TIMESTAMP',

    // 12 JSON Utilities
    'utils.get-field-desc': 'Extracts a field from the body JSON. Returns empty if the field doesn\'t exist or is <code>null</code>.',
    'utils.get-required-desc': 'Like <code>get_json_field</code> but returns 1 if the field is empty. Useful combined with <code>||</code>.',

    // 13 Full Example
    'example.p1': 'Complete CRUD for posts with validations, JOIN and migration.',
    'example.h3-migration': 'Migration',
    'example.h3-handler': 'Route handler',
    'example.h3-test': 'Test with curl',

    // 14 API Reference
    'apiref.p1': 'Endpoints available in the default installation.',
    'apiref.th-method': 'Method',
    'apiref.th-response': 'Response',
    'apiref.th-desc': 'Description',
    'apiref.root-desc': 'Root health check',
    'apiref.users-list': 'List all users',
    'apiref.users-create': 'Create a user',
    'apiref.users-get': 'Get a user by ID',
    'apiref.users-update': 'Update a user',
    'apiref.users-delete': 'Delete a user',
    'apiref.products-list': 'List all products',
    'apiref.products-create': 'Create a product',
    'apiref.products-get': 'Get a product by ID',
    'apiref.products-update': 'Update a product',
    'apiref.products-delete': 'Delete a product',
    'apiref.orders-list': 'List all orders (with JOIN users + products)',
    'apiref.orders-get': 'Get an order by ID',
    'apiref.orders-create': 'Create an order',

    // 15 Roadmap
    'roadmap.p1': 'Planned improvements ordered by impact on performance and scalability.',
    'roadmap.empty': 'No items with that status.',
    'roadmap.filter-all': 'all',
    'roadmap.h4-problem': 'Problem',
    'roadmap.h4-fix': 'Fix',
    'roadmap.impact-label': 'IMPACT',
    'roadmap.badge-title': 'Click to change status',
    'roadmap.status.pending': 'pending',
    'roadmap.status.in-progress': 'in progress',
    'roadmap.status.done': 'done',
    'roadmap.status.blocked': 'blocked',
  },

  es: {
    // Hero
    'hero.tagline': 'Pure Bash REST API Framework',
    'hero.desc': 'ShellRest es un framework HTTP escrito completamente en Bash 5+. Sin dependencias de runtime — solo <code>bash</code>, <code>sqlite3</code>, <code>jq</code> y <code>nc</code>. Router con path params, ORM-like helpers, sistema de migraciones, middleware pipeline.',

    // 01 Overview
    'overview.p1': 'ShellRest convierte un script Bash en un servidor HTTP funcional. Cada request dispara un proceso hijo que sourcéa el framework, matchea la ruta, ejecuta el handler y devuelve una respuesta HTTP/1.1 completa.',
    'overview.stack-title': '<strong style="color:var(--text-bright)">Stack mínimo requerido:</strong>',
    'overview.flow-title': '<strong style="color:var(--text-bright)">Flujo de una request:</strong>',
    'overview.callout': 'Cada request es un proceso Bash independiente. No hay estado compartido entre requests — todo estado persiste en SQLite.',
    'pipeline.nc': 'nc (acepta TCP)',

    // 02 Quick Start
    'qs.h3-clone': 'Clonar e inicializar',
    'qs.h3-first': 'Primera request',
    'qs.h3-route': 'Crear una ruta nueva en 60 segundos',
    'qs.callout': 'ShellRest carga automáticamente todos los <code>*.sh</code> dentro de <code>routes/</code>. No necesitas registrar el archivo.',

    // 03 Project Structure
    'tree.server': '# Servidor TCP — arranca nc en loop',
    'tree.api': '# Entry point por request — parsea HTTP, ejecuta pipeline',
    'tree.migrate': '# Runner de migraciones',
    'tree.make-migration': '# Generador de archivos de migración',
    'tree.env': '# Variables de entorno (opcional)',
    'tree.shellrest': '# Core del framework',
    'tree.config': '# load_config, get_config, debug_log',
    'tree.http': '# http_response, parse_query_string, get_header',
    'tree.router': '# register_route, route_request, match_route_pattern',
    'tree.database': '# execute_query, escape_sql',
    'tree.middleware': '# add_middleware, run_middleware, middlewares built-in',
    'tree.migration': '# Schema builder + migration tracking',
    'tree.utils': '# db_select/insert/update/delete/join, json_error',
    'tree.validation': '# validate_json, validate_email, validate_integer…',
    'tree.routes': '# Handlers de rutas (carga automática)',
    'tree.migrations-dir': '# Archivos de migración (ordenados por timestamp)',

    // 04 Configuration
    'config.p1': 'ShellRest lee configuración desde <code>.env</code> en la raíz del proyecto. Todas las variables son opcionales — si no existen, se usan los defaults.',
    'config.th1': 'Variable',
    'config.th2': 'Default',
    'config.th3': 'Descripción',
    'config.api-port-desc': 'Puerto TCP donde escucha el servidor',
    'config.api-host-desc': 'Host del servidor',
    'config.db-file-desc': 'Ruta al archivo SQLite. Relativa a la raíz del proyecto',
    'config.log-file-desc': 'Ruta al log de acceso escrito por <code>logging_middleware</code>',
    'config.debug-desc': 'Habilita <code>debug_log()</code> — escribe a stderr',
    'config.cors-origin-desc': 'Valor del header <code>Access-Control-Allow-Origin</code>',
    'config.cors-methods-desc': 'Métodos HTTP permitidos por CORS',
    'config.cors-headers-desc': 'Headers permitidos por CORS',
    'config.h3-api': 'API de configuración',
    'config.load-config-desc': 'Carga el archivo <code>.env</code> y exporta todas las variables con sus defaults. Se llama automáticamente en <code>api.sh</code> y <code>server.sh</code>.',
    'config.get-config-desc': 'Retorna el valor de una clave de configuración por nombre.',
    'config.param-th2': 'Tipo',
    'config.param-th3': 'Valores válidos',
    'config.debug-log-desc': 'Escribe a stderr solo cuando <code>DEBUG=true</code>. No tiene efecto en producción.',

    // 05 Routing
    'routing.p1': 'El router usa arrays asociativos de Bash para mapear <code>METHOD PATH</code> → función handler. Soporta rutas exactas y rutas con path parameters (<code>{param}</code>).',
    'routing.h3-params': 'Path Parameters',
    'routing.params-p': 'Los segmentos entre llaves <code>{nombre}</code> en el patrón se extraen automáticamente y se pasan al handler como argumentos posicionales en el orden en que aparecen en el path.',
    'routing.h3-query': 'Query String',
    'routing.query-p': 'Los query params se parsean con <code>parse_query_string</code> y se exportan como variables con prefijo <code>QUERY_</code>.',
    'routing.callout': 'El array global <code>PATH_PARAMS</code> también está disponible: <code>${PATH_PARAMS["id"]}</code>. Los args posicionales son más convenientes para la mayoría de los casos.',
    'routing.register-desc': 'Registra una ruta asociando un método HTTP y un patrón de path con una función Bash.',
    'routing.th-type': 'Tipo',
    'routing.th-desc': 'Descripción',
    'routing.pattern-desc': 'Path con soporte para <code>{param}</code> y wildcard <code>*</code>',
    'routing.handler-desc': 'Nombre de la función Bash que maneja la request',
    'routing.get-header-desc': 'Busca un header HTTP por nombre (case-insensitive) en la request actual. Retorna vacío si no existe.',
    'routing.load-routes-desc': 'Sourcéa todos los <code>*.sh</code> dentro del directorio especificado. Se llama automáticamente en <code>api.sh</code>. Cada archivo puede registrar las rutas que quiera.',

    // 06 HTTP Responses
    'http.response-desc': 'Escribe una respuesta HTTP/1.1 completa a stdout, incluyendo headers CORS automáticos y <code>Content-Length</code> calculado.',
    'http.th-examples': 'Ejemplos',
    'http.h3-helpers': 'Helpers de respuesta',
    'http.json-error-desc': 'Retorna un JSON de error estándar: <code>{"error":"message"}</code>',
    'http.json-success-desc': 'Retorna un JSON de éxito estándar: <code>{"message":"..."}</code>',
    'http.h3-cors': 'Headers CORS',
    'http.cors-p': 'Todos los headers CORS se inyectan automáticamente en cada llamada a <code>http_response</code>. Se controlan desde <code>.env</code>:',

    // 07 Database
    'db.p1': 'ShellRest usa SQLite vía CLI (<code>sqlite3</code>). El módulo <code>utils.sh</code> provee helpers de alto nivel sobre <code>execute_query</code>. Todo retorna JSON por defecto.',
    'db.h3-basic': 'Queries básicos',
    'db.h3-count': 'Conteo y existencia',
    'db.h3-utils': 'Utilidades de DB',
    'db.select-desc': 'Ejecuta un SELECT y retorna el resultado. Formato JSON por defecto.',
    'db.th-desc': 'Descripción',
    'db.param-table': 'Nombre de la tabla',
    'db.param-fields': 'Columnas a seleccionar',
    'db.param-where': 'Cláusula WHERE (sin la palabra WHERE)',
    'db.param-format': 'Formato de salida',
    'db.insert-desc': 'Ejecuta un INSERT. Usar <code>safe_sql_string()</code> para escapar valores de texto.',
    'db.update-desc': 'Ejecuta un UPDATE. Verificar <code>db_get_changes()</code> para saber si afectó filas.',
    'db.delete-desc': 'Ejecuta un DELETE. Verificar <code>db_get_changes()</code> para confirmar que algo fue eliminado.',
    'db.count-desc': 'Retorna el número de filas que cumplen la condición.',
    'db.exists-desc': 'Retorna 0 (true) si existe al menos una fila que cumpla la condición, 1 (false) si no.',
    'db.inner-join-desc': 'INNER JOIN entre dos tablas.',
    'db.left-join-desc': 'LEFT JOIN entre dos tablas. Incluye filas de <code>table1</code> sin match en <code>table2</code>.',
    'db.multi-join-desc': 'JOIN múltiple con soporte completo para GROUP BY, HAVING, ORDER BY y LIMIT.',
    'db.aggregate-desc': 'Queries de agregación — SUM, COUNT, AVG, MIN, MAX con GROUP BY y HAVING.',
    'db.execute-desc': 'Ejecuta SQL arbitrario contra la base de datos. Retorna el resultado en el formato especificado.',
    'db.safe-sql-desc': 'Escapa comillas simples y envuelve el valor en comillas SQL. <strong>Siempre usar para valores de texto en queries.</strong>',
    'db.callout': 'Nunca interpolar variables directamente en queries sin <code>safe_sql_string()</code>. Los valores numéricos validados con <code>validate_integer()</code> son la única excepción segura.',

    // 08 Validation
    'val.p1': 'Módulo de validación para inputs de usuario. Todas las funciones retornan 0 (success) o 1 (failure) para uso directo en condicionales.',
    'val.required-desc': 'Verifica que todos los campos especificados existan y no sean nulos en el JSON recibido.',
    'val.email-desc': 'Valida formato de email con regex. No verifica existencia del dominio.',
    'val.integer-desc': 'Verifica que el valor sea un entero positivo (<code>[0-9]+</code>). Útil para IDs antes de usarlos en queries.',
    'val.path-param-desc': 'Valida que un path param sea entero. Si falla, escribe automáticamente un <code>400</code> y retorna 1. Patrón estándar en todos los handlers con <code>{id}</code>.',
    'val.json-desc': 'Verifica que el string sea JSON válido usando <code>jq empty</code>.',
    'val.sanitize-desc': 'Elimina caracteres de control no imprimibles (<code>\\x00-\\x1F</code> y <code>\\x7F</code>) del input.',

    // 09 Middleware
    'mw.p1': 'El middleware pipeline se ejecuta <em>antes</em> de que la request llegue al route handler. Si un middleware retorna 1 (failure), el pipeline se detiene y no se llama al handler.',
    'mw.add-desc': 'Agrega una función al pipeline. El orden de llamada refleja el orden de registro.',
    'mw.h3-builtin': 'Middlewares built-in',
    'mw.logging-p': 'Escribe cada request a <code>$LOG_FILE</code> con timestamp, método y path.',
    'mw.cors-p': 'Intercepta requests <code>OPTIONS</code> (preflight) y responde <code>204 No Content</code> con los headers CORS. Para el resto de métodos, retorna 0 y deja pasar.',
    'mw.auth-p': 'Ejemplo incluido: protege rutas bajo <code>/protected/*</code>. Verifica que el header <code>Authorization</code> esté presente; si no, responde <code>401</code>.',
    'mw.h3-custom': 'Middleware custom',
    'mw.custom-p': 'Un middleware es cualquier función Bash que recibe <code>(method, path, body)</code> y retorna 0 para continuar o 1 para cortar el pipeline.',
    'mw.pipe-request': 'Request',
    'mw.pipe-auth': 'auth_middleware (opt)',

    // 10 Migrations
    'mg.p1': 'El sistema de migraciones trackea qué scripts ya se ejecutaron en la tabla <code>migrations</code> de SQLite. Cada migración tiene funciones <code>up()</code> y <code>down()</code>.',
    'mg.h3-commands': 'Comandos de migrate.sh',
    'mg.h3-create': 'Crear una migración',
    'mg.create-p': 'El script genera un archivo con timestamp en <code>migrations/</code> listo para editar:',

    // 11 Schema Builder
    'schema.p1': 'Helpers que generan fragmentos de DDL SQL. Se usan dentro de las funciones <code>up()</code> de las migraciones.',
    'schema.h3-constraints': 'Constraints e Indexes',
    'schema.th-fn': 'Función',
    'schema.th-sql': 'SQL generado',
    'schema.th-sig': 'Firma',
    'schema.no-params': 'sin parámetros',
    'schema.timestamps-desc': 'sin parámetros — agrega ambas',
    'schema.datetime-desc': '(name, default="", nullable=true) — usa "now" para CURRENT_TIMESTAMP',

    // 12 JSON Utilities
    'utils.get-field-desc': 'Extrae un campo del JSON del body. Retorna vacío si el campo no existe o es <code>null</code>.',
    'utils.get-required-desc': 'Como <code>get_json_field</code> pero retorna 1 si el campo está vacío. Útil en combinación con <code>||</code>.',

    // 13 Full Example
    'example.p1': 'CRUD completo de posts con validaciones, JOIN y migración.',
    'example.h3-migration': 'Migración',
    'example.h3-handler': 'Route handler',
    'example.h3-test': 'Test con curl',

    // 14 API Reference
    'apiref.p1': 'Endpoints disponibles en la instalación por defecto.',
    'apiref.th-method': 'Método',
    'apiref.th-response': 'Respuesta',
    'apiref.th-desc': 'Descripción',
    'apiref.root-desc': 'Health check raíz',
    'apiref.users-list': 'Lista todos los usuarios',
    'apiref.users-create': 'Crea un usuario',
    'apiref.users-get': 'Obtiene un usuario por ID',
    'apiref.users-update': 'Actualiza un usuario',
    'apiref.users-delete': 'Elimina un usuario',
    'apiref.products-list': 'Lista todos los productos',
    'apiref.products-create': 'Crea un producto',
    'apiref.products-get': 'Obtiene un producto por ID',
    'apiref.products-update': 'Actualiza un producto',
    'apiref.products-delete': 'Elimina un producto',
    'apiref.orders-list': 'Lista todas las órdenes (con JOIN users + products)',
    'apiref.orders-get': 'Obtiene una orden por ID',
    'apiref.orders-create': 'Crea una orden',

    // 15 Roadmap
    'roadmap.p1': 'Mejoras planificadas ordenadas por impacto en rendimiento y escalabilidad.',
    'roadmap.empty': 'No hay items con ese estado.',
    'roadmap.filter-all': 'todos',
    'roadmap.h4-problem': 'Problema',
    'roadmap.h4-fix': 'Fix',
    'roadmap.impact-label': 'IMPACTO',
    'roadmap.badge-title': 'Click para cambiar estado',
    'roadmap.status.pending': 'pendiente',
    'roadmap.status.in-progress': 'en progreso',
    'roadmap.status.done': 'completado',
    'roadmap.status.blocked': 'bloqueado',
  },
};

// ── I18N ENGINE ───────────────────────────────────────────────────────────
let currentLang = localStorage.getItem('shellrest-lang') || 'en';

function t(key) {
  return TRANSLATIONS[currentLang]?.[key] ?? TRANSLATIONS['en']?.[key] ?? key;
}

function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    el.textContent = t(el.dataset.i18n);
  });
  document.querySelectorAll('[data-i18n-html]').forEach(el => {
    el.innerHTML = t(el.dataset.i18nHtml);
  });
  document.documentElement.lang = currentLang;
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.lang === currentLang);
  });
}

function setLang(lang) {
  currentLang = lang;
  localStorage.setItem('shellrest-lang', lang);
  applyTranslations();
  if (typeof renderRoadmap === 'function') renderRoadmap();
}

document.addEventListener('DOMContentLoaded', applyTranslations);
