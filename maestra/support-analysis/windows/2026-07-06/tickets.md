# tickets — week 2026-07-06 (ISO 2026-W28, Mon 06 – Sun 12 Jul)

Stage 1 (find). Candidates only — not yet classified. Stage 2 reads each and drops false positives.

- **Track:** both
- **ClearFeed coll 4 (product-support):** 73 requests in window → 9 personalization candidates
- **Slack #csm-support:** no `/personalization/` link matches; 1 thread found by keyword (reco/popup quality) — flagged, see note
- **Custom-code mechanics (omega, lower bound):** 83 created in window → **60 with custom code** (html/css 58 · targeting 8 · integration 10), 25 tenants

Host boundary note: window bucketed by `created::date` in DB tz. Mechanic URLs built best-effort as `https://<client>.maestra.io/personalization/<type>/<proxy_id>`.

---

## Section A — Support tickets/threads

```
- [ ] t01 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783324216522549 | ?          | 2026-07-06 | Unable to load the reco reports
- [ ] t02 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783404130532209 | ilovelinen | 2026-07-07 | /personalization/reco-widget/58508/settings — "что-то не так" с настройками реко
- [ ] t03 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783414698568809 | ?          | 2026-07-07 | Unable to copy the widgets
- [ ] t04 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783520462864959 | zone3      | 2026-07-08 | Zone3: show a unique promo code per customer on final pop-up screen ("not possible right now")
- [ ] t05 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783521312507119 | lucyandyak | 2026-07-08 | lucyayk: лимитировать показ одного варианта для многих групп id
- [ ] t06 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783588274253819 | ?          | 2026-07-09 | Не работают рекомендации на проекте
- [ ] t07 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783675108722909 | marathonbet-eu | 2026-07-10 | /personalization/pop-up/59532 — не запускается попап, тестовая ссылка не формируется
- [ ] t08 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783688232330459 | lucyandyak | 2026-07-10 | "опять проблема с люси" (vague — read to classify/drop)
- [ ] t09 | clearfeed | https://maestraio.slack.com/archives/C08FEDXGQUC/p1783712821634339 | lectricebikes | 2026-07-10 | Lectric Ebikes quiz troubleshooting (borderline — is quiz a personalization mechanic?)
- [ ] t10 | slack     | https://maestraio.slack.com/archives/C089G0JMXJP/p1783520425179659?thread_ts=1782911849.751909 | lucyandyak | 2026-07-08 | #csm-support: Lucy&Yak reco quality (duplicate products across a rec, swatches) + signup popup+modal — thread started 06-30, active in-window
```

> Note (t10 / Slack recall): #csm-support had **no** message with a `/personalization/` link in the window. This thread was surfaced by keyword (reco/popup) and its parent is 2026-06-30 (before the window). Included as a candidate but flagged — see the end-of-run question on whether Slack matching should stay link-only or also match keywords.

---

## Section B — Custom-code mechanics (omega DB, lower bound)

60 mechanics, grouped by tenant. Buckets: `h`=html/css, `t`=targeting JS, `i`=integration JS.

```
# zone3 — 17 (reco-widget ×16, pop-up ×1) · all html/css
- [ ] m01 | zone3 | reco-widget | 59519 | 2026-07-07 | h
- [ ] m02 | zone3 | reco-widget | 59520 | 2026-07-07 | h
- [ ] m03 | zone3 | reco-widget | 59523 | 2026-07-07 | h
- [ ] m04 | zone3 | reco-widget | 59524 | 2026-07-07 | h
- [ ] m05 | zone3 | reco-widget | 59525 | 2026-07-07 | h
- [ ] m06 | zone3 | reco-widget | 59526 | 2026-07-07 | h
- [ ] m07 | zone3 | reco-widget | 59527 | 2026-07-07 | h
- [ ] m08 | zone3 | reco-widget | 59540 | 2026-07-08 | h
- [ ] m09 | zone3 | reco-widget | 59541 | 2026-07-08 | h
- [ ] m10 | zone3 | reco-widget | 59542 | 2026-07-08 | h
- [ ] m11 | zone3 | reco-widget | 59548 | 2026-07-08 | h
- [ ] m12 | zone3 | reco-widget | 59549 | 2026-07-08 | h
- [ ] m13 | zone3 | reco-widget | 59550 | 2026-07-08 | h
- [ ] m14 | zone3 | reco-widget | 59551 | 2026-07-08 | h
- [ ] m15 | zone3 | reco-widget | 59552 | 2026-07-08 | h
- [ ] m16 | zone3 | reco-widget | 59553 | 2026-07-08 | h
- [ ] m17 | zone3 | pop-up | 59570 | 2026-07-09 | h
# marathonbet-eu — 8 (pop-up) · html/css + targeting JS
- [ ] m18 | marathonbet-eu | pop-up | 59531 | 2026-07-08 | h,t
- [ ] m19 | marathonbet-eu | pop-up | 59532 | 2026-07-08 | h,t
- [ ] m20 | marathonbet-eu | pop-up | 59533 | 2026-07-08 | h,t
- [ ] m21 | marathonbet-eu | pop-up | 59534 | 2026-07-08 | h,t
- [ ] m22 | marathonbet-eu | pop-up | 59535 | 2026-07-08 | h,t
- [ ] m23 | marathonbet-eu | pop-up | 59536 | 2026-07-08 | h,t
- [ ] m24 | marathonbet-eu | pop-up | 59589 | 2026-07-10 | h,t
- [ ] m25 | marathonbet-eu | pop-up | 59590 | 2026-07-10 | h,t
# Lucyandyak — 5 (reco-widget ×2, inline-block ×3) · 2 w/ integration JS
- [ ] m26 | Lucyandyak | reco-widget | 58503 | 2026-07-06 | h,i
- [ ] m27 | Lucyandyak | reco-widget | 58509 | 2026-07-07 | h
- [ ] m28 | Lucyandyak | inline-block | 59544 | 2026-07-08 | h
- [ ] m29 | Lucyandyak | inline-block | 59545 | 2026-07-08 | h
- [ ] m30 | Lucyandyak | inline-block | 59585 | 2026-07-10 | h,i
# Deako — 3 · 1 w/ integration JS
- [ ] m31 | Deako | reco-widget | 59514 | 2026-07-07 | h
- [ ] m32 | Deako | reco-widget | 59528 | 2026-07-07 | h,i
- [ ] m33 | Deako | inline-block | 59577 | 2026-07-09 | h
# betboom — 3 (pop-up) · html/css
- [ ] m34 | betboom | pop-up | 59587 | 2026-07-10 | h
- [ ] m35 | betboom | pop-up | 59593 | 2026-07-10 | h
- [ ] m36 | betboom | pop-up | 59594 | 2026-07-10 | h
# tail (2 or 1 each)
- [ ] m37 | 1winstore | inline-block | 59530 | 2026-07-08 | h
- [ ] m38 | 1winstore | pop-up | 59603 | 2026-07-12 | h
- [ ] m39 | BookDepot | inline-block | 59564 | 2026-07-09 | h
- [ ] m40 | BookDepot | inline-block | 59565 | 2026-07-09 | h
- [ ] m41 | drhonow | inline-block | 59591 | 2026-07-10 | h
- [ ] m42 | drhonow | reco-widget | 59592 | 2026-07-10 | h,i
- [ ] m43 | Onethrive | inline-block | 59558 | 2026-07-08 | h
- [ ] m44 | Onethrive | inline-block | 59560 | 2026-07-08 | h
- [ ] m45 | AlmondCow | pop-up | 59588 | 2026-07-10 | h,i
- [ ] m46 | BlueQ | pop-up | 58507 | 2026-07-06 | h,i
- [ ] m47 | Limevizio | pop-up | 58501 | 2026-07-06 | h,i
- [ ] m48 | sarahssilks | reco-widget | 59561 | 2026-07-08 | h,i
- [ ] m49 | urbanarmorgear | pop-up | 59567 | 2026-07-09 | i
- [ ] m50 | Demonstration | pop-up | 59586 | 2026-07-10 | i
- [ ] m51 | bedkingdom | reco-widget | 58500 | 2026-07-06 | h
- [ ] m52 | hoeglcom | inline-block | 58512 | 2026-07-07 | h
- [ ] m53 | ilovelinen | reco-widget | 59566 | 2026-07-09 | h
- [ ] m54 | Nationsphotolab | inline-block | 59595 | 2026-07-10 | h
- [ ] m55 | natvbasics | inline-block | 59563 | 2026-07-09 | h
- [ ] m56 | 4ocean | pop-up | 59578 | 2026-07-09 | h
- [ ] m57 | pescatoreny | pop-up | 58502 | 2026-07-06 | h
- [ ] m58 | selkirkcom | reco-widget | 59598 | 2026-07-10 | h
- [ ] m59 | SvahaUSA | inline-block | 59599 | 2026-07-09 | h
- [ ] m60 | tac | reco-widget | 59574 | 2026-07-09 | h
```

Enrichment plan for Section B: cluster-level (not 60 individual stories). Sample zone3 reco variants (m01–m16), marathonbet targeting+html popups (m18–m25), and the 10 integration-JS bodies to characterise the reasons; the long html/css tail is one pattern (hand-authored variant markup). The **60 count is the metric**; the reasons are grouped.
