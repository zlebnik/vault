---
_favorite: true
_favorite_index: 2
_organized: true
---
# Maestra — Tasks

## Active — my move

- [ ] **Bot escalations (застарелое, ответить):**
  - CF DeviceUUID missing (Lucy&Yak, thread p1784624284) — Alex, 28+ дней, гипотеза incognito/adblock

## Waiting on others

- [ ] **CF-1120 — Selkirk 5-product «complete the look» carousel: дубли между луками** — Sasha Haishun + Phil _(issue #1048)_
  07.09 Sasha фолоуап: одинаковые товары в 3 луках (Trailblazer + Wanderer collections пересекаются). Gleb: в одном виджете геморно (в код персонализации лезть), теоретически можно подублировать прицельно по ID; Sasha сначала пойдёт уговаривать клиента на «без повторов».
  Issue: https://github.com/maestra-io/issues-maestra/issues/1048
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1779822892936139

## To verify

- [ ] **CF-2271 — zone3 scenarios/26151 не запускается** — Alexandra Ryazantseva
  Gleb: «фигня с тем как агент создаёт самый первый multibranch, пересоздай вручную». Жду фидбек.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1788534123954769


- [ ] **Anna #ps — «делал такое Gleb в отпуске»** — Anna Stepanova
  Посмотрел, разобрался, жду ответа.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1788261202606959

- [ ] **Retro next-step: найти eSIM для SMS в Штатах** — Gleb (self)
  Сделано, проверить.
  Miro: https://miro.com/app/board/uXjVISpu5Fg=/

## Scheduled / future

- [ ] **⚠️ 4ocean legal + tech pack** — Alex Gornik + Ivan Borovikov _(на 08.09)_
  28.08: Alex прошёлся по контракту, оставил 8 пунктов: (1) EU data flow audit — карта endpoints, blocker; (2) DPA с consent warranty, 48h/72h cure, audit right; (3) disclosure package — endpoints + live funnels/domains; (4) access rework per Exhibit A — named accounts, GTM edit-without-publish, Meta partner на их pixel, Shopify collaborators; (5) consent gating — скрипты в GTM gallery через Usercentrics или Shopify Web Pixels; (6) §11 written approval для CSM-автоматизаций + AI-inside-Maestra clarify; (7) asset check — ничего 4ocean в Maestra-owned BM/MCC; (8) internal runbook на 48h/72h clocks. Alex просит формально канал алертов для 48-72h notice.
  Thread: https://maestraio.slack.com/archives/C07KJ72STNW/p1787441940582009

- [ ] **⚠️ Onsite tracker vs. cookie consent — Almond Cow / Aeropress / Larixon** — Philipp + Alex Gornik + Konstantin _(на 08.09)_
  Almond Cow (Shopify, US): `tracker.js` не грузится до consent → email click attribution ломается (click-id теряется). Klaviyo грузится immediately silent + буферит pageview. Договорились: всегда грузить tracker, но silent без consent (no cookies/id/requests), буферить первый pageview (click-id, utm, landing, referrer) в sessionStorage, flush на consent. Плюс Aeropress: попап показывается только после refresh (второй экран), должен сразу после Accept. Phil попросил 3-option setting в аппке: (a) fire after consent (4ocean legal), (b) silent before + fire on consent, (c) fire before consent. Пересекается с CF-2058 (Larixon bazaraki.com GDPR). Временно для almondcow tracker вставлен прямо в theme.
  Threads: https://maestraio.slack.com/archives/C07KJ72STNW/p1787601544278379
  CF-2058 (Larixon): https://maestraio.slack.com/archives/C08FEDXGQUC/p1787222258117929
