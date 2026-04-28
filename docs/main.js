// ── ROADMAP DATA ──────────────────────────────────────────────────────────
const ROADMAP = [
  {
    id: "p1",
    priority: "CRITICAL",
    title: {
      en: "Concurrency — replace nc + FIFO with socat fork",
      es: "Concurrencia — reemplazar nc + FIFO con socat fork",
    },
    status: "pending",
    file: "server.sh:23",
    desc: {
      en: "<code>server.sh</code> uses a loop with <code>nc</code> + FIFO — one connection at a time. Concurrent requests queue up or are dropped. No real parallelism.",
      es: "<code>server.sh</code> usa un loop con <code>nc</code> + FIFO — una sola conexión a la vez. Requests concurrentes esperan en cola o se pierden. No hay paralelismo real.",
    },
    problem: {
      label: {
        en: "server.sh — current",
        es: "server.sh — actual",
      },
      code: `while true; do\n    nc -l -p \${PORT} < "$PIPE" | ./api.sh > "$PIPE"\n    # ↑ bloquea hasta que termina. Siguiente request espera.\ndone`,
    },
    fix: {
      label: {
        en: "server.sh — proposed",
        es: "server.sh — propuesto",
      },
      code: `socat TCP-LISTEN:\${PORT},fork,reuseaddr EXEC:"$(dirname "$0")/api.sh"\n# fork = proceso hijo por conexión. Concurrencia real.`,
    },
    note: {
      en: "Without this fix the server is single-threaded. One slow handler blocks all other clients.",
      es: "Sin este fix el servidor es single-threaded. Un handler lento bloquea a todos los demás clientes.",
    },
  },
  {
    id: "p2",
    priority: "HIGH",
    title: {
      en: "Body reading — replace dd bs=1 with head -c",
      es: "Lectura de body — reemplazar dd bs=1 con head -c",
    },
    status: "pending",
    file: "api.sh:58",
    desc: {
      en: "Each POST/PUT body is read with <code>dd bs=1</code> — one syscall per byte. A 100KB payload generates 102,400 unnecessary syscalls.",
      es: "El body de cada POST/PUT se lee con <code>dd bs=1</code> — una syscall por byte. Un payload de 100KB genera 102,400 syscalls innecesarias.",
    },
    problem: {
      label: {
        en: "api.sh:58 — current",
        es: "api.sh:58 — actual",
      },
      code: `body=$(dd bs=1 count="$content_length" 2>/dev/null)\n#         ↑ 1 byte por syscall = O(n) overhead`,
    },
    fix: {
      label: {
        en: "api.sh:58 — proposed",
        es: "api.sh:58 — propuesto",
      },
      code: `body=$(head -c "$content_length")\n#           ↑ lee el chunk completo en una sola operación`,
    },
  },
  {
    id: "p3",
    priority: "MEDIUM",
    title: {
      en: "Debug logs — remove hardcoded echo statements in production",
      es: "Debug logs — eliminar echo hardcodeados en production",
    },
    status: "pending",
    file: "api.sh:43,44,56,59",
    desc: {
      en: "<code>api.sh</code> has 4 active <code>echo \"DEBUG: ...\" >> debug.log</code> lines in production. Synchronous disk I/O on every request; file grows without limit or rotation.",
      es: "<code>api.sh</code> tiene 4 líneas <code>echo \"DEBUG: ...\" >> debug.log</code> activas en producción. I/O de disco síncrono en cada request, archivo crece sin límite ni rotación.",
    },
    problem: {
      label: {
        en: "api.sh — lines to remove",
        es: "api.sh — líneas a eliminar",
      },
      code: `echo "DEBUG: request_line='$request_line'" >> debug.log   # línea 43\necho "DEBUG: METHOD='$REQUEST_METHOD' PATH='$REQUEST_PATH'" >> debug.log  # línea 44\necho "DEBUG: content_length='$content_length'" >> debug.log  # línea 56\necho "DEBUG: body='$body'" >> debug.log  # línea 59`,
    },
    fix: {
      label: {
        en: "replace with debug_log()",
        es: "reemplazar con debug_log()",
      },
      code: `# Solo activa si DEBUG=true en .env\ndebug_log "request_line='$request_line'"\ndebug_log "METHOD='$REQUEST_METHOD' PATH='$REQUEST_PATH'"`,
    },
  },
  {
    id: "p4",
    priority: "LOW",
    title: {
      en: "Double source — remove redundant imports in route files",
      es: "Double source — eliminar imports redundantes en route files",
    },
    status: "pending",
    file: "routes/*.sh:3-5",
    desc: {
      en: "Each route file sources <code>http.sh</code>, <code>database.sh</code> and <code>utils.sh</code> at the top. <code>api.sh</code> already loaded them before calling <code>load_routes()</code> — they are parsed and executed twice per request.",
      es: "Cada route file sourcéa <code>http.sh</code>, <code>database.sh</code> y <code>utils.sh</code> al inicio. <code>api.sh</code> ya los cargó antes de llamar <code>load_routes()</code> — se parsean y ejecutan dos veces por request.",
    },
    problem: {
      label: {
        en: "routes/users.sh — current",
        es: "routes/users.sh — actual",
      },
      code: `#!/bin/bash\n\nsource "shellrest/http.sh"      # ← ya cargado por api.sh\nsource "shellrest/database.sh"  # ← ya cargado por api.sh\nsource "shellrest/utils.sh"     # ← ya cargado por api.sh\n\nregister_route "GET" "/users" "get_users"`,
    },
    fix: {
      label: {
        en: "routes/users.sh — proposed",
        es: "routes/users.sh — propuesto",
      },
      code: `#!/bin/bash\n\n# Sin source — el contexto ya existe cuando api.sh llama load_routes()\nregister_route "GET" "/users" "get_users"`,
    },
  },
];

// ── ROADMAP CONFIG ────────────────────────────────────────────────────────
const PRIORITY_CFG = {
  CRITICAL: { color: "var(--red)",    bg: "#1a0a0a", border: "var(--red)" },
  HIGH:     { color: "var(--amber)",  bg: "#1a1200", border: "var(--amber)" },
  MEDIUM:   { color: "var(--cyan)",   bg: "#001a22", border: "var(--cyan)" },
  LOW:      { color: "var(--green)",  bg: "#0a1a0a", border: "var(--green)" },
};

const STATUS_CFG = {
  "pending":     { label: { en: "pending",     es: "pendiente"   }, color: "var(--text-dim)", bg: "var(--bg3)", border: "var(--border)", icon: "○" },
  "in-progress": { label: { en: "in progress", es: "en progreso" }, color: "var(--amber)",    bg: "#1a1200",    border: "var(--amber)",  icon: "◑" },
  "done":        { label: { en: "done",        es: "completado"  }, color: "var(--green)",    bg: "#0a1a0a",    border: "var(--green)",  icon: "●" },
  "blocked":     { label: { en: "blocked",     es: "bloqueado"   }, color: "var(--red)",      bg: "#1a0a0a",    border: "var(--red)",    icon: "✕" },
};

// ── ROADMAP RENDERER ──────────────────────────────────────────────────────
let activeFilter = "all";

function getLang() {
  return typeof currentLang !== 'undefined' ? currentLang : 'en';
}

function termBlock(label, code) {
  const escaped = code
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
  return `
    <div class="term" style="margin:10px 0 14px">
      <div class="term-bar">
        <span class="term-dot r"></span><span class="term-dot y"></span><span class="term-dot g"></span>
        <span class="term-title">${label}</span>
      </div>
      <div class="term-body">
        <pre><code class="language-bash">${escaped}</code></pre>
      </div>
    </div>`;
}

function renderCard(item) {
  const p    = PRIORITY_CFG[item.priority];
  const s    = STATUS_CFG[item.status];
  const lang = getLang();
  const title       = item.title[lang]          ?? item.title.en;
  const desc        = item.desc[lang]           ?? item.desc.en;
  const statusLabel = s.label[lang]             ?? s.label.en;
  const problemLabel = item.problem.label[lang] ?? item.problem.label.en;
  const fixLabel     = item.fix.label[lang]     ?? item.fix.label.en;
  const note = item.note
    ? `<div class="callout callout-danger" style="margin-top:0"><strong>${t('roadmap.impact-label')}</strong> ${item.note[lang] ?? item.note.en}</div>`
    : "";

  return `
  <div class="fn-card roadmap-card" data-status="${item.status}" data-id="${item.id}">
    <div class="fn-header" style="justify-content:space-between;flex-wrap:wrap;gap:8px;">
      <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
        <span style="color:${p.color};font-size:11px;font-weight:bold;background:${p.bg};border:1px solid ${p.border};padding:2px 8px;border-radius:3px;white-space:nowrap">${item.priority}</span>
        <span class="fn-name">${title}</span>
      </div>
      <div style="display:flex;align-items:center;gap:8px;">
        <span style="color:var(--text-dim);font-size:11px;font-family:var(--font)">${item.file}</span>
        <span class="roadmap-status-badge" data-id="${item.id}"
          style="color:${s.color};font-size:11px;background:${s.bg};border:1px solid ${s.border};padding:2px 10px;border-radius:3px;cursor:pointer;white-space:nowrap;user-select:none;"
          title="${t('roadmap.badge-title')}"
        >${s.icon} ${statusLabel}</span>
      </div>
    </div>
    <div class="fn-body">
      <div class="fn-desc">${desc}</div>
      <h4>${t('roadmap.h4-problem')}</h4>
      ${termBlock(problemLabel, item.problem.code)}
      <h4>${t('roadmap.h4-fix')}</h4>
      ${termBlock(fixLabel, item.fix.code)}
      ${note}
    </div>
  </div>`;
}

function renderFilters() {
  const statuses = ["all", ...Object.keys(STATUS_CFG)];
  const counts   = { all: ROADMAP.length };
  const lang     = getLang();
  ROADMAP.forEach(i => { counts[i.status] = (counts[i.status] || 0) + 1; });

  return statuses.map(s => {
    const isAll  = s === "all";
    const cfg    = isAll ? null : STATUS_CFG[s];
    const label  = isAll ? t('roadmap.filter-all') : (cfg?.label[lang] ?? cfg?.label.en);
    const count  = counts[s] || 0;
    const active = s === activeFilter;
    const color  = isAll ? "var(--text)" : (cfg?.color || "var(--text-dim)");
    const border = active ? color : "var(--border)";
    const bg     = active ? (isAll ? "var(--bg3)" : cfg?.bg) : "transparent";

    return `<button onclick="setFilter('${s}')"
      style="font-family:var(--font);font-size:11px;cursor:pointer;padding:3px 10px;border-radius:3px;
             border:1px solid ${border};background:${bg};color:${color};transition:all 0.15s;">
      ${label} <span style="opacity:0.6">(${count})</span>
    </button>`;
  }).join("");
}

function renderRoadmap() {
  const list    = document.getElementById("roadmap-list");
  const filters = document.getElementById("roadmap-filters");
  if (!list || !filters) return;

  const visible = activeFilter === "all"
    ? ROADMAP
    : ROADMAP.filter(i => i.status === activeFilter);

  filters.innerHTML = renderFilters();
  list.innerHTML = visible.length
    ? visible.map(renderCard).join("")
    : `<div style="color:var(--text-dim);padding:24px 0;font-size:13px;">${t('roadmap.empty')}</div>`;

  list.querySelectorAll("code.language-bash").forEach(el => hljs.highlightElement(el));

  list.querySelectorAll(".roadmap-status-badge").forEach(badge => {
    badge.addEventListener("click", () => cycleStatus(badge.dataset.id));
  });
}

function setFilter(status) {
  activeFilter = status;
  renderRoadmap();
}

function cycleStatus(id) {
  const order = ["pending", "in-progress", "done", "blocked"];
  const item  = ROADMAP.find(i => i.id === id);
  if (!item) return;
  const idx   = order.indexOf(item.status);
  item.status = order[(idx + 1) % order.length];
  renderRoadmap();
}

// ── SCROLLSPY ─────────────────────────────────────────────────────────────
function initScrollspy() {
  const navItems = document.querySelectorAll('.nav-item');
  const sections = document.querySelectorAll('section[id], #hero');

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        navItems.forEach(item => item.classList.remove('active'));
        const active = document.querySelector(`.nav-item[href="#${entry.target.id}"]`);
        if (active) active.classList.add('active');
      }
    });
  }, { rootMargin: '-20% 0px -70% 0px' });

  sections.forEach(s => observer.observe(s));
}

// ── COPY BUTTON ───────────────────────────────────────────────────────────
function copyCode(btn) {
  const termBody = btn.closest('.term-bar').nextElementSibling;
  const code = termBody.querySelector('code') || termBody;
  navigator.clipboard.writeText(code.innerText).then(() => {
    btn.textContent = 'copied!';
    btn.style.color = 'var(--green)';
    setTimeout(() => {
      btn.textContent = 'copy';
      btn.style.color = '';
    }, 1500);
  });
}

// ── INIT ──────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  hljs.highlightAll();
  renderRoadmap();
  initScrollspy();
});
