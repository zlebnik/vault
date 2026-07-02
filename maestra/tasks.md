---
_favorite: true
_favorite_index: 2
_organized: true
---
# Maestra — Tasks

## Active — my move

- [ ] **CF-672 reopened — Julia Lo: sena widget dedup / control когда recs load** — Julia Lo
  Julia 29.06 reopened: убрать targeting нельзя (виджет полностью исчезает), но с ним «filter out duplicates» ломает соседние reco. Прямой вопрос: обсуждаем ли improvements по control когда recs load? Ответить + подумать про фичу.
  Widget: https://sena.maestra.io/personalization/reco-widget/52707
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1773338878182269

- [ ] **CF-1407 — Julia Lo hawaiicoffee: апгрейд темплейтов виджетов до new version** — Julia Lo
  Re-ask 24.06: «could I get your help updating hawaiicoffee widget templates to the newer version» (формат/функционал стрелочек). Gleb: «Sure! All of them, right?». Делать миграцию на бэкенде без пересоздания виджетов (analytics не ломать).
  Folder: https://hawaiicoffee.maestra.io/newcampaigns/reco-widgets?folder=3ab8e393-3d98-4b1f-93d2-e0b0eeeae58d
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782324762714079

- [ ] **CF-1384 — selkirkcom: chat + Fabio's errors (San Diego)** — Phil + Sasha
  Чат уже починил («говна поел, довольно оригинально»). Fabio ошибку с ходу не откопал — нужен ещё подход. Скрин получил.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782235350667279

- [ ] **CF-1315 zone3 reco — плавающий баг мобиле** _(Alexandra: Samsung S25 + Samsung fold)_ — Eugenia + Alexandra
  «Дорваться» до этих девайсов и воспроизвести. Карточка слева уходит за экран, при каждом прокручивании всё больше. По дизайну: часть второй карточки торчит справа.
  Widget: https://zone3.maestra.io/personalization/reco-widget/55349
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781675187671859

- [ ] **#alerts-critical — Roman: «знаешь что-то про такие алерты?»** _(non-urgent)_ — Roman Ivonin
  Roman: «не срочно. это как ни странно не я». Посмотреть alert thread.
  Thread: https://maestraio.slack.com/archives/C09KCTYR9BL/p1782238780492839

- [ ] **#top-secret-devs — Ruslan: «у нас в клод дизайн по итогу наша нормальная дизайн система подтянута?»** — Ruslan Temirgaliev
  Прямой вопрос, ответить.
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1782235209831359

- [ ] **MCP MR #166 (перса) — Roman feedback** — Roman Ivonin
  Roman: «вроде всё по мете. Попроси агента посмотреть на единообразие параметров и поведения с campaign_list, если ещё нет. + сделать хотя бы по одному snapshot-тесту golden path через tooltester».
  MR: https://mindbox.gitlab.yandexcloud.net/development/mcp/-/merge_requests/166
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1782915817553059

- [ ] **Banner carousel: полноценный UI для Swiper settings** _(CF-1020 auto-closed, effort card создан, в pipeline)_ — Julia Lo
  ClearFeed auto-closed после 3 недель. Effort card в Notion. Делать сам dev-work.
  Notion: https://www.notion.so/364e0880507881398261fcf9e23f04a9
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1778625361282019

## Waiting on others

- [ ] **CF-1428 — Efraim lead-gen popup dup phone (design discussion с Артёмом)** — Artem Zavgorodnii
  01.07: расписал root cause. profile A с unconfirmed phone блокирует B с тем же phone (2% error rate = 14 of 642 calls). Артём предложил «captured email на новый profile при phone-конфликте» + отдельная регистрация email/phone. «Needs some thinking». Ждём дизайн-решение Артёма.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782422545098389

- [ ] **CF-1430 — hawaiicoffee BigCommerce dropdown variant (widget 58272)** — Eugenia + Julia Lo
  Варианты из коробки не работают на BigCommerce. Отправил пример ожидаемого JSON-фида (variants per товар: картинка, цена, название). Eu пошла к Julia уточнить про сбор фида. Артёму fyi.
  Widget: https://hawaiicoffee.maestra.io/personalization/reco-widget/58272
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782457814996109

- [ ] **CF-1343 — Efraim popup image padding** — Efraim Hermes
  Спросил «did you try set width? у тебя size 40% поэтому padding». Пинганул ещё раз 25.06. Жду ответ.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781787520745879

- [ ] **CF-1268 — frontend-фикс сделан, ждём DB-backfill (Roman)** — Roman
  Frontend-фикс выкатил: галку убрал, по дефолту доступ передаётся. Попросил Roman «может ещё в базах замигрировать, чтобы у всех было сразу». Жду Roman.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781231580695349

- [ ] **Julia P. 3 articles — финальный review дал** — Julia Pogrebnaia
  25.06: посмотрел все 3 статьи. 1 и 2 OK (отметил битые symbols в troubleshooting в article 1, скрин дал). По article 3 — стоит упомянуть, что в headless mode клиент может делать server-side или direct API calls без site personalization. Жду Julia P apply.
  Thread: https://maestraio.slack.com/archives/C0A36LV9XEG/p1782332023283429

- [ ] **CF-1120 — Selkirk 5-product carousel** — Philipp + Sasha Haishun
  01.07 объяснил структуру + пинганул Sasha «как прогресс, нужна ещё помощь?». Ждём.
  Prototype: https://selkirkcom.maestra.io/personalization/reco-widget/58101
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1779822892936139

- [ ] **CF-1351 — Anna lucyandyak custom forms** — Anna Stepanova
  Спросил «чем не подходят стандартные шаблоны?», пинганул ещё раз 01.07 «Ань, вернёшься?». Жду ответ.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781849978020609

- [ ] **CF-798 — Julia: quiz attribution → product rec** _(low prio, на Danil)_ — Julia Lo + Danil
  Reopened Julia: переключить attribution с embedded form на product rec. Danil обещал revisit. Не мой scope, тикет ассайнен на меня по умолчанию.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1775227485867179

- [ ] **Popup-вёрстка-skill ownership** — Roman + Phil
  Roman: «не хочу, чтобы ты был ответственным. CSM сами драйвят. Найдут и анонсируют».
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1781195064381849

## To verify

- [ ] **CF-1469 — Coolibar: product images отображаются неверно при выборе item** — Alexandra Ryazantseva
  30.06: создал GitHub issue #1133. Ждём разбирательство.
  Issue: https://github.com/maestra-io/issues-maestra/issues/1133
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782831586584899

- [ ] **Shopify-app: сделать ID блока обязательным** — Артём подтвердил
  Не на мне, проверить когда выкатят.
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1779115929682469

- [ ] **Trashie errors после фиксов** — Alex Glazkov + ClearFeed bot
  Дать ответ — residual ожидаемые или нужны ещё фиксы.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1780920351147619

## Scheduled / future
