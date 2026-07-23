export const meta = {
  name: 'support-analysis-enrich',
  description: 'Stage 2 — enrich personalization support threads (ClearFeed + Slack) into structured entries',
  phases: [{ title: 'Enrich', detail: 'batched subagents read each thread and classify' }],
};

// --- args guard -------------------------------------------------------------
// The candidate list arrives as `args`. Depending on how the workflow is
// launched, `args` may reach the script as an actual array OR as a JSON string.
// A 2026-07 run (W29) passed it as a string; `"[...]".slice(i,i+4)` then chopped
// the raw JSON into ~500 fragments → 530 subagents / ~27M tokens. Normalize and
// hard-assert here so that can never happen again.
let CANDIDATES = args;
if (typeof CANDIDATES === 'string') {
  try { CANDIDATES = JSON.parse(CANDIDATES); }
  catch (e) { throw new Error('enrich.wf: args is a string but not valid JSON: ' + e.message); }
}
if (!Array.isArray(CANDIDATES)) {
  throw new Error('enrich.wf: args must be an array of candidate objects, got ' + typeof CANDIDATES);
}
if (CANDIDATES.length === 0) throw new Error('enrich.wf: no candidates supplied');
if (CANDIDATES.length > 100) throw new Error('enrich.wf: refusing ' + CANDIDATES.length + ' candidates (>100 cap) — likely a malformed args payload');
for (const [i, c] of CANDIDATES.entries()) {
  if (!c || typeof c !== 'object' || !c.id || !c.source) {
    throw new Error('enrich.wf: candidate[' + i + '] is malformed (need at least {id, source}): ' + JSON.stringify(c));
  }
}

const BATCH_SIZE = 4;
const batches = [];
for (let i = 0; i < CANDIDATES.length; i += BATCH_SIZE) batches.push(CANDIDATES.slice(i, i + BATCH_SIZE));
if (batches.length > 30) throw new Error('enrich.wf: ' + batches.length + ' batches exceeds the 30-batch runaway cap');
log(`enrich.wf: ${CANDIDATES.length} candidates → ${batches.length} batches of ≤${BATCH_SIZE}`);

// --- contract ---------------------------------------------------------------
const CONTRACT = `
You are enriching ONE batch of personalization support threads for a weekly support-toil analysis (Maestra personalization: pop-ups, inline blocks, reco widgets, targeting).

First load the tools you need in ONE call:
ToolSearch query "select:mcp__claude_ai_ClearFeed__requests_get,mcp__claude_ai_Slack__slack_read_thread"

For EACH candidate:
- clearfeed → mcp__claude_ai_ClearFeed__requests_get { secondary_id: <n>, include: ["messages"] }
- slack     → mcp__claude_ai_Slack__slack_read_thread { channel_id: <cid>, message_ts: <ts> }
Read the FULL thread before classifying. Keep investigation proportionate.

Return one entry per candidate with these fields:
- id: carry the candidate id verbatim (t01 / s01 …).
- keep: true only if this is a real PRODUCT PERSONALIZATION matter (pop-up / inline block / reco widget / targeting / on-site personalization). false for mailings, scenarios/flows, segments, webhooks, DNS, billing, infra, raw-data exports, generic platform. Non-personalization → keep:false + drop_reason.
- group: exactly one of Bug | New client setup | Missing feature | Custom code | How-to.
  Classify by the FIX THE CAUSE NEEDS, not by today's workaround. If the product simply can't do X → Missing feature even if the stopgap is hand-coded. Custom code = when hand-written HTML/CSS/JS IS the accepted mechanism (client-owned script failing, genuine one-off). How-to = pure product-knowledge/clarification question with no defect or gap.
- client: the tenant (mindbox system name / brand). "?" if truly unknown from the thread.
- root_cause: a USER STORY — "As a <role>, I <need/hit> <situation> because <underlying reason>." The WHY it existed, not a restatement of the symptom.
- current_solution: how it's handled today (hand-written JS, manual DB fix, workaround, eng shipped a fix, told client to…), or "none".
- repetitive: true if a pattern likely to recur, false if genuinely one-off. Judge honestly.
- pain: one line, the actual user pain.
- match_hint: a short kebab phrase naming the underlying cause (e.g. "reco-out-of-stock-variants") so the reconcile step can match it to the registry. Optional.
- drop_reason: only when keep:false (incl. "thread unreadable: <error>" if a tool is unavailable).
`;

const SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    entries: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        properties: {
          id: { type: 'string' }, keep: { type: 'boolean' },
          group: { type: 'string', enum: ['Bug', 'New client setup', 'Missing feature', 'Custom code', 'How-to'] },
          client: { type: 'string' }, root_cause: { type: 'string' },
          current_solution: { type: 'string' }, repetitive: { type: 'boolean' },
          pain: { type: 'string' }, match_hint: { type: 'string' }, drop_reason: { type: 'string' },
        },
        required: ['id', 'keep', 'group', 'client', 'root_cause', 'current_solution', 'repetitive', 'pain'],
      },
    },
  },
  required: ['entries'],
};

// --- fan out ----------------------------------------------------------------
const results = await parallel(batches.map((batch, bi) => () =>
  agent(
    CONTRACT + '\n\nCANDIDATES (JSON):\n' + JSON.stringify(batch, null, 2),
    { label: `enrich:batch${bi + 1}`, phase: 'Enrich', model: 'sonnet', schema: SCHEMA }
  )
));

const entries = results.filter(Boolean).flatMap(r => r.entries || []);
// keep only real candidate ids that we actually sent, dedupe (most-complete wins)
const sent = new Set(CANDIDATES.map(c => c.id));
const byId = {};
const score = e => (e.root_cause || '').length + (e.current_solution || '').length + (e.keep ? 50 : 0) + (e.match_hint ? 20 : 0);
for (const e of entries) {
  if (!sent.has(e.id)) continue;
  if (!byId[e.id] || score(e) > score(byId[e.id])) byId[e.id] = e;
}
const clean = Object.values(byId);
log(`enrich.wf: ${clean.length}/${CANDIDATES.length} candidates enriched`);
return { entries: clean, batches: batches.length };
