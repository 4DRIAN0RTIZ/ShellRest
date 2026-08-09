// ── CHANGELOG ─────────────────────────────────────────────────────────────
const CHANGELOG_REPO = "https://github.com/4drian0rtiz/shellrest";

const CHANGELOG_GROUP_TAGS = {
  "Features":      "tag-feat",
  "Bug Fixes":     "tag-fix",
  "Documentation": "tag-docs",
  "Refactor":      "tag-refactor",
  "Performance":   "tag-feat",
};

let changelogData = null;

function getLang() {
  return typeof currentLang !== 'undefined' ? currentLang : 'en';
}

async function loadChangelogData() {
  if (changelogData) return changelogData;
  const res = await fetch('changelog.json');
  if (!res.ok) throw new Error('changelog.json not found');
  changelogData = await res.json();
  return changelogData;
}

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

function renderChangelogEmpty(container) {
  container.innerHTML = `<div style="color:var(--text-dim);padding:24px 0;font-size:13px;">${t('changelog.empty')}</div>`;
}

async function loadChangelog() {
  const container = document.getElementById("changelog-content");
  if (!container) return;

  try {
    const releases = await loadChangelogData();
    const release = (releases || []).find(r => (r.commits || []).length > 0);
    if (!release) {
      renderChangelogEmpty(container);
      return;
    }

    const version = release.version || "Unreleased";
    const timestamp = release.commits[0]?.author?.timestamp;
    const date = timestamp ? new Date(timestamp * 1000).toISOString().slice(0, 10) : "";

    const entries = release.commits.map(c => {
      const tagClass = CHANGELOG_GROUP_TAGS[c.group] || "tag-chore";
      const sha = (c.id || "").slice(0, 7);
      const url = c.id ? `${CHANGELOG_REPO}/commit/${c.id}` : null;
      return `
      <div class="changelog-entry">
        <span class="tag ${tagClass}">${escapeHtml(c.group || "Other")}</span>
        <span>${escapeHtml(c.message || "")}</span>
        ${url ? `<a href="${url}" target="_blank" rel="noopener">${sha}</a>` : ""}
      </div>`;
    }).join("");

    container.innerHTML = `
    <div class="changelog-version">
      <h3>${escapeHtml(version)} ${date ? `<span class="changelog-date">— ${date}</span>` : ""}</h3>
      ${entries}
    </div>`;

    const footerUpdated = document.getElementById("footer-updated");
    if (footerUpdated && date) {
      footerUpdated.textContent = `· ${t('changelog.updated')}${date}`;
    }
  } catch (e) {
    console.error('Error rendering changelog:', e);
    renderChangelogEmpty(container);
  }
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

// ── VERSION ───────────────────────────────────────────────────────────────
async function loadSidebarVersion() {
  try {
    const data = await loadChangelogData();
    const version = data[0]?.version;
    if (!version) throw new Error('Version not found in changelog.json');
    ['sidebar-version-tag', 'hero-version-tag', 'footer-version-tag'].forEach(id => {
      const el = document.getElementById(id);
      if (el) el.textContent = version;
    });
  } catch (error) {
    console.error('Error fetching changelog.json:', error);
  }
}

// ── INIT ──────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  hljs.highlightAll();
  loadChangelog();
  initScrollspy();
  loadSidebarVersion();
});
