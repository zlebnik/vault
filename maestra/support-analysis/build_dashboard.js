#!/usr/bin/env node
// Canonical, deterministic dashboard builder (stage 40).
// Reads root-causes/registry.json (authoritative accumulator) + each
// windows/<mon>/tickets.md (the per-entry thread index) and regenerates:
//   - dashboard/data.json           (machine-readable, schemaVersion 2)
//   - dashboard/index.html          (injects the same JSON into #toil-data)
//   - root-causes/registry.md       (human-readable ranked registry)
// No dependencies. Per-window support-by-group and custom-code figures are
// DERIVED from the registry — do not hand-maintain them here.

'use strict';
const fs = require('fs');
const path = require('path');

const base = path.resolve(__dirname);
const reg = JSON.parse(fs.readFileSync(path.join(base, 'root-causes/registry.json'), 'utf8'));

const GROUPS = ['Bug', 'New client setup', 'Missing feature', 'Custom code', 'How-to'];
const GROUP_ORDER = Object.fromEntries(GROUPS.map((g, i) => [g, i]));

// Curated short labels for the dashboard (registry `story` is the long user-story).
const SHORT = {
  'rc-mf-reco-variant-dedup': 'Reco widget repeats colour variants (SKU dedup, no swatches, no self-serve)',
  'rc-cc-popup-inline-template-gap': 'Pop-up / inline-block template gap → hand-authored markup',
  'rc-cc-targeting-gtm-gating': 'Custom JS targeting (GTM/consent, language, currency, delay, hours)',
  'rc-cc-popup-integration-ops': 'Integration JS for API ops, add-to-cart, form handling',
  'rc-mf-reco-theme-slot-injection': 'No native theme-aware placement (slot / header / cart drawer)',
  'rc-cc-no-custom-code-guardrails': 'No lint/validation gate on custom code → ships broken',
  'rc-mf-popup-per-customer-promocode': 'Pop-up can’t show a per-customer promo code',
  'rc-mf-reco-single-algo-per-slot': 'Reco widget limited to one algorithm per slot',
  'rc-bug-targeting-reach-api-triggered': 'Targeting reach = 0 for API-triggered widgets',
  'rc-bug-popup-editor-unsaved-guard': 'Pop-up editor lost unsaved edits (fixed MR !8819)',
  'rc-bug-reco-replace-content-race': 'Reco A/B replace-content race → empty/flickering widget',
  'rc-bug-reco-widget-copy-perf': 'Reco-widget copy slow / errors',
  'rc-cc-client-owned-js-breaks-reco': 'Client-owned custom JS zeroes reco eligibility',
  'rc-bug-popup-ab-migration': 'Migration left A/B config broken',
  'rc-bug-popup-sms-auth-intermittent': 'Pop-up SMS auth code intermittently failed',
  'rc-mf-computed-props-custom-event-fields': "Computed properties can't aggregate custom event fields",
  'rc-mf-reco-mechanic-limit-visibility': 'Undisclosed reco-mechanic cap, no self-serve visibility',
  'rc-mf-reco-template-upgrade-selfserve': 'No self-serve reco-widget template upgrade / per-device width',
  'rc-cc-dom-dependent-targeting-breaks': 'Custom DOM-matching targeting breaks on client markup changes',
  'rc-mf-popup-lead-dropped-phone-collision': 'Lead-gen pop-up silently drops submissions on phone collision',
  'rc-mf-reco-no-variant-data': 'No product variant data for reco widget dropdowns',
  'rc-howto-reco-preset-purchased-exclusion': 'How-to: which reco presets exclude already-purchased products',
  'rc-bug-phone-format-validation': 'Phone-format validation missing countries (fixed GH #1071)',
  'rc-mf-reco-yotpo-ratings-integration': 'No native Yotpo ratings integration for reco widgets',
  'rc-bug-checkout-reco-settings-ignored': 'Checkout reco widget settings ignored (Shopify-side)',
  'rc-bug-geotargeting-exclusion-ignored': 'Geotargeting country-exclusion ignored (fixed)',
  'rc-bug-reco-carousel-mobile-device': 'Reco carousel breaks on specific Android devices',
  'rc-bug-popup-rotation-perf-under-load': 'Popup rotation degrades under traffic surge',
  'rc-mf-per-device-placement-selector': 'No per-device CSS selector for widget placement',
  'rc-cc-editor-no-script-tag': 'Custom-code editor rejects <script> tags',
  'rc-bug-popup-image-responsive-padding': 'Popup image padding differs desktop vs mobile',
  'rc-mf-reco-bundle-discount-on-add': 'Bundle reco: no discount-only-when-added-from-rec',
  'rc-mf-reco-widget-visual-customization': 'Reco widget visual customization not self-serve (CSS/arrows/carousel)',
  'rc-bug-popup-partial-submission-dropoff': 'Pop-up partial-submission misses code-confirm dropoff (lost subs)',
  'rc-mf-reco-image-optimization': 'Reco image optimization all-or-nothing (slow vs low quality)',
  'rc-bug-reco-report-assisted-revenue-double-count': 'Reco BI report double-counts assisted revenue (~3x AOV)',
  'rc-mf-shopify-two-way-sync': 'No two-way sync of pop-up/segment data to Shopify',
  'rc-howto-popup-form-config': 'How-to: pop-up form field config + capture-on-close',
  'rc-howto-reco-silent-misconfig': "How-to: reco widget silently broken when a setting isn't enabled",
  'rc-bug-popup-editor-hidden-field': 'Pop-up editor hides name field → stuck placeholder in live pop-up',
  'rc-bug-reco-variant-selector-broken': 'Checkout reco variant selector / product name not rendering',
  'rc-bug-reco-update-pipeline-stuck': 'Reco update pipeline stuck (stale items, no alerting)',
  'rc-bug-reco-zero-weight-algo-op': 'Reco op called even when algorithm weight = 0 (failed ops)',
  'rc-bug-reco-min-count-selector-embed': 'Reco min-product-count hide broken on selector-embed',
  'rc-howto-reco-ab-participant-counting': 'How-to: reco A/B participant counting (eligibility vs render)',
  'rc-cc-legacy-tracker-per-theme-layout': 'Legacy manual tracker install fails per theme layout / after rename',
  'rc-bug-popup-heading-textarea-regression': 'Pop-up heading text→textarea change broke all pop-ups',
  'rc-bug-reco-custom-js-vanishes': 'Reco widget custom JS silently vanishes (no audit log)',
  'rc-bug-reco-widget-load-latency': 'Reco widget backend load latency (slow CDP lookups)',
  'rc-bug-popup-regional-render': 'Pop-up regional rendering bug',
  'rc-mf-reco-ranking-opacity-tuning': 'Reco ranking opaque + popularity lookback not tunable',
  'rc-bug-reco-preview-hash-missing': 'Reco preview settings hash unresolvable in DB',
  'rc-bug-inline-block-form-localization-missing': 'Inline-block settings form missing localization',
  'rc-mf-reco-explicit-cart-rules': 'No explicit cart-based reco rules + fallback',
  'rc-mf-subscription-source-attribution': 'No subscription-source attribution (pop-up vs registration)',
};
const shortOf = (c) => SHORT[c.id] || (c.story || '').split('.')[0].slice(0, 80);

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// ISO-week label + Mon–Sun range from a "YYYY-MM-DD" Monday (UTC to avoid TZ drift).
function weekMeta(monday) {
  const d = new Date(monday + 'T00:00:00Z');
  const end = new Date(d.getTime() + 6 * 86400000);
  // ISO week number
  const t = new Date(d.getTime());
  t.setUTCDate(t.getUTCDate() + 3); // nearest Thursday
  const isoYear = t.getUTCFullYear();
  const week1 = new Date(Date.UTC(isoYear, 0, 4));
  const week = 1 + Math.round(((t - week1) / 86400000 - 3 + ((week1.getUTCDay() + 6) % 7)) / 7);
  const iso = `${isoYear}-W${String(week).padStart(2, '0')}`;
  const pad = (n) => String(n).padStart(2, '0');
  const sM = d.getUTCMonth(), eM = end.getUTCMonth();
  const range = sM === eM
    ? `${pad(d.getUTCDate())}–${pad(end.getUTCDate())} ${MONTHS[sM]}`
    : `${pad(d.getUTCDate())} ${MONTHS[sM]}–${pad(end.getUTCDate())} ${MONTHS[eM]}`;
  return { iso, range };
}

// Parse a window's tickets.md pipe rows: "- [ ] t01 | source | url | client | date | summary".
// Returns { id: {source, url, client, date, summary} } (empty if no file / no rows).
function parseTickets(window) {
  const f = path.join(base, 'windows', window, 'tickets.md');
  if (!fs.existsSync(f)) return {};
  const out = {};
  for (const line of fs.readFileSync(f, 'utf8').split('\n')) {
    const m = line.match(/^\s*-\s*\[[ xX]\]\s*(.+)$/);
    if (!m) continue;
    const cols = m[1].split('|').map((s) => s.trim());
    if (cols.length < 3 || !/^[ts]\d+$/.test(cols[0])) continue;
    const [id, source, url, client, date, ...rest] = cols;
    out[id] = { source, url: url || null, client: client || null, date: date || null, summary: rest.join(' | ') || null };
  }
  return out;
}

const isThreadAnchor = (a) => /^[ts]\d+$/.test(a);
const anchorOf = (entry) => (entry.match(/#(.+)$/) || [])[1];

// --- assemble windows ---
const windowIds = reg.custom_code_totals.map((w) => w.window).sort();
const cctByWin = Object.fromEntries(reg.custom_code_totals.map((w) => [w.window, w]));

const windows = windowIds.map((w) => {
  const support = Object.fromEntries(GROUPS.map((g) => [g, 0]));
  const tix = parseTickets(w);
  const entries = [];
  for (const c of reg.root_causes) {
    const o = c.occurrences.find((x) => x.window === w);
    if (!o || !o.tickets) continue;
    support[c.group] += o.tickets;
    const anchors = (o.entries || []).map(anchorOf).filter(isThreadAnchor);
    if (anchors.length) {
      for (const a of anchors) {
        const t = tix[a] || {};
        entries.push({
          id: a, group: c.group, cause: c.id, causeStory: shortOf(c),
          client: t.client || (c.clients && c.clients[0]) || null,
          source: t.source || null, url: t.url || null, summary: t.summary || null,
        });
      }
    } else {
      // ticket occurrence with no per-thread anchor (e.g. only a `cc` aggregate) — label-only rows
      for (let i = 0; i < o.tickets; i++) {
        entries.push({
          id: null, group: c.group, cause: c.id, causeStory: shortOf(c),
          client: (c.clients && c.clients[0]) || null, source: null, url: null, summary: null,
        });
      }
    }
  }
  entries.sort((a, b) => (GROUP_ORDER[a.group] - GROUP_ORDER[b.group]) || (a.id || '').localeCompare(b.id || ''));
  const supportTickets = Object.values(support).reduce((a, b) => a + b, 0);
  const cct = cctByWin[w];
  return {
    week: w, ...weekMeta(w), track: 'both', support, supportTickets,
    customCode: { total: cct.distinct, htmlcss: cct.htmlcss, targeting: cct.targeting, integration: cct.integration },
    entries,
  };
});

// --- recurring causes (ranked) with thread lists ---
const ticketsByWin = Object.fromEntries(windowIds.map((w) => [w, parseTickets(w)]));
const recurring = reg.root_causes.map((c) => {
  const threads = [];
  for (const o of c.occurrences) {
    for (const e of (o.entries || [])) {
      const a = anchorOf(e);
      if (!isThreadAnchor(a)) continue;
      const t = (ticketsByWin[o.window] || {})[a] || {};
      threads.push({
        week: o.window, id: a,
        client: t.client || (c.clients && c.clients[0]) || null,
        source: t.source || null, url: t.url || null, summary: t.summary || null,
      });
    }
  }
  threads.sort((a, b) => b.week.localeCompare(a.week) || (a.id || '').localeCompare(b.id || ''));
  return {
    id: c.id, group: c.group, story: shortOf(c),
    total_tickets: c.total_tickets, total_mechanics: c.total_mechanics,
    weeks: c.occurrences.length, last_seen: c.last_seen, threads,
  };
}).sort((a, b) => (b.total_tickets - a.total_tickets) || (b.total_mechanics - a.total_mechanics));

const data = {
  schemaVersion: 2,
  groups: GROUPS,
  updated: process.env.DASH_UPDATED || windowIds[windowIds.length - 1],
  windows,
  recurring,
};

// --- write data.json + inject into index.html ---
const json = JSON.stringify(data, null, 2);
fs.writeFileSync(path.join(base, 'dashboard/data.json'), json + '\n');
let h = fs.readFileSync(path.join(base, 'dashboard/index.html'), 'utf8');
h = h.replace(/(<script id="toil-data" type="application\/json">)[\s\S]*?(<\/script>)/, '$1\n' + json + '\n$2');
fs.writeFileSync(path.join(base, 'dashboard/index.html'), h);

// --- registry.md ---
const spanStr = (c) => c.occurrences.length === 1
  ? c.first_seen.slice(5)
  : c.first_seen.slice(5) + '→' + c.last_seen.slice(5);
let md = `# Root-cause registry\n\nAccumulated across all weekly windows. Generated from \`registry.json\` by \`build_dashboard.js\` (stage 30/40) — **do not hand-edit**. Ranked by tickets, then mechanics. Custom-code mechanic counts are omega lower bounds and overlap across causes; exact per-window bucket figures live in \`registry.json → custom_code_totals\`.\n\n**Windows covered:** ${windowIds.join(', ')} (${windowIds.length}). **Causes:** ${reg.root_causes.length}. **Recurring (≥2 weeks):** ${reg.root_causes.filter((c) => c.occurrences.length >= 2).length}.\n\n| # | Root cause | Group | Tickets | Mechanics | Weeks | Span |\n|---|-----------|-------|--------:|----------:|------:|------|\n`;
recurring.forEach((c, i) => {
  const full = reg.root_causes.find((x) => x.id === c.id);
  md += `| ${i + 1} | ${c.story} | ${c.group} | ${c.total_tickets} | ${c.total_mechanics} | ${c.weeks} | ${spanStr(full)} |\n`;
});
md += `\n---\n\n**Recurring across ≥2 weeks (the durable toil):**\n\n`;
for (const c of reg.root_causes.filter((x) => x.occurrences.length >= 2).sort((a, b) => b.occurrences.length - a.occurrences.length || b.total_mechanics - a.total_mechanics)) {
  const per = c.occurrences.map((o) => `${o.window.slice(5)}:${o.tickets}t/${o.mechanics}m`).join(' · ');
  md += `- **${shortOf(c)}** (\`${c.id}\`) — ${c.total_tickets}t / ${c.total_mechanics}m over ${c.occurrences.length}w · ${per}\n`;
}
md += `\n**Merge watch:** \`rc-cc-no-custom-code-guardrails\` ↔ \`rc-cc-client-owned-js-breaks-reco\` (custom code fails silently, no validation gate); \`rc-cc-dom-dependent-targeting-breaks\` ↔ \`rc-cc-targeting-gtm-gating\` (custom JS targeting). Merge if they keep co-occurring.\n\n**Resolved:** rc-bug-popup-editor-unsaved-guard (MR !8819) — should not recur.\n`;
fs.writeFileSync(path.join(base, 'root-causes/registry.md'), md);

// --- verify + report ---
const m = h.match(/<script id="toil-data"[^>]*>([\s\S]*?)<\/script>/);
const d = JSON.parse(m[1]);
console.log('windows=' + d.windows.map((w) => w.iso).join(',') + ' recurring=' + d.recurring.length);
let allOk = true;
for (const w of d.windows) {
  const s = Object.values(w.support).reduce((a, b) => a + b, 0);
  const ok = s === w.supportTickets;
  allOk = allOk && ok;
  console.log(`  ${w.iso} ${w.range}: support ${s}==${w.supportTickets} ${ok ? '✓' : '✗'} · entries ${w.entries.length} · cc ${w.customCode.total}`);
}
const withUrl = d.windows.reduce((a, w) => a + w.entries.filter((e) => e.url).length, 0);
const totalEntries = d.windows.reduce((a, w) => a + w.entries.length, 0);
console.log(`entry thread-links: ${withUrl}/${totalEntries} have URLs`);
console.log(`registry.md written · sums ${allOk ? 'OK' : 'MISMATCH'}`);
