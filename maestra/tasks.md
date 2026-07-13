---
_favorite: true
_favorite_index: 2
_organized: true
---
# Maestra — Tasks

## Active — my move

- [ ] **furniturefairnet: улучшить CheckoutContactInfoSubmitted (не вызывать без данных)** — Alex Glazkov
  Alex Glazkov 07.07: drhonow с 03.07 без ошибок (app embed tracker fix помог). А у furniturefairnet CheckoutContactInfoSubmitted всё ещё сыпет. Просит доулучшить чтобы не вызывать если нет данных по контакту.
  Failed logs: https://furniturefairnet.maestra.io/integration-logs/operations?operation=furniturefairnet.Shopify.CheckoutContactInfoSubmitted&operations-status=Failed
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783428508223759

- [ ] **CF-1610 — Sasha Haishun: Lectric Ebikes quiz + виджет reco (перезавести тест)** — Sasha Haishun
  Sasha 13.07: Фил попросил перезавести тест на Lectric eBikes. Старый widget 58262, новый 59616. Full контекст в #dev-general.
  Widget new: https://lectricebikes.maestra.io/personalization/reco-widget/59616
  Thread: https://maestraio.slack.com/archives/D09LNLKC4TZ/p1783955703639869

- [ ] **selkirkcom / SvahaUSA: clear cart after CheckoutCompleted (pixel fix)** — Alex Glazkov
  13.07: Price Drop email на уже купленный товар. Alex: cart не очищается после checkout из-за async processing. Клиент репортит несколько раз в неделю. Alex просит quick fix в pixel logic — на trigger «Checkout completed» вызывать «Update cart» для очистки. Alex: «may be more interesting than I thought», продолжает копать.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783944702245289

- [ ] **CF-1564 — Eugenia lucyandyak: reco не подгружаются в мини-корзину без reload** — Eugenia Smirnova
  Site не обновляет страницу с корзиной, из-за этого reco не подтягиваются. Разобрал: сайт хитро себя ведёт, нужен код блока целиком. «Цепанем в спринте», делать нашу карточку.
  Widget: https://lucyandyak.maestra.io/personalization/reco-widget/58077
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783510386327129

- [ ] **CF-672 reopened — Julia Lo: sena widget dedup / control когда recs load** — Julia Lo
  Julia 29.06 reopened: убрать targeting нельзя (виджет полностью исчезает), но с ним «filter out duplicates» ломает соседние reco. Прямой вопрос: обсуждаем ли improvements по control когда recs load? Ответить + подумать про фичу.
  Widget: https://sena.maestra.io/personalization/reco-widget/52707
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1773338878182269

- [ ] **CF-1384 — selkirkcom: chat + Fabio's errors (San Diego)** — Phil + Sasha
  Чат уже починил («говна поел, довольно оригинально»). Fabio ошибку с ходу не откопал — нужен ещё подход. Скрин получил.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782235350667279

- [ ] **#alerts-critical — Roman: «знаешь что-то про такие алерты?»** _(non-urgent)_ — Roman Ivonin
  Roman: «не срочно. это как ни странно не я». Посмотреть alert thread.
  Thread: https://maestraio.slack.com/archives/C09KCTYR9BL/p1782238780492839

- [ ] **#top-secret-devs — Ruslan: «у нас в клод дизайн по итогу наша нормальная дизайн система подтянута?»** — Ruslan Temirgaliev
  Прямой вопрос, ответить.
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1782235209831359

## Waiting on others

- [ ] **CF-1315 — zone3 reco Samsung S25/fold** _(жду видео от Alexandra)_ — Eugenia + Alexandra
  06.07 Alexandra спросила когда возьмусь. Не нашёл людей с этими телефонами; попросил её записать видео для помощи с воспроизведением.
  Widget: https://zone3.maestra.io/personalization/reco-widget/55349
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781675187671859

- [ ] **Banner carousel: полноценный UI для Swiper settings** _(CF-1020 auto-closed, effort card, в pipeline)_ — Julia Lo
  Effort card в Notion. Waiting в pipeline.
  Notion: https://www.notion.so/364e0880507881398261fcf9e23f04a9
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1778625361282019

- [ ] **CF-1522 — Anna: lucyandyak Tapcart integration** — Anna Stepanova
  07.07: эффорт заведён, Anna: «когда лучше вернуться за апдейтом?». Gleb: «через пару недель, скорее всего». Waiting.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783343092698879

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

- [ ] **CF-798 — Julia: quiz attribution → product rec** _(low prio, на Danil)_ — Julia Lo + Danil
  Reopened Julia: переключить attribution с embedded form на product rec. Danil обещал revisit. Не мой scope, тикет ассайнен на меня по умолчанию.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1775227485867179

- [ ] **Popup-вёрстка-skill ownership** — Roman + Phil
  Roman: «не хочу, чтобы ты был ответственным. CSM сами драйвят. Найдут и анонсируют».
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1781195064381849

## To verify

- [ ] **CF-1483 — atlantacutlery loyalty (доделано, ждёт verify)** — Alexandra Ryazantseva
  Rewards JSON image + Redeem15 разобрал, отдал. Проверить у Alexandra что всё ok.
  Popup: https://atlantacutlery.maestra.io/personalization/pop-up/58408
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1782923957849159

- [ ] **CF-1497 — Alexandra: pop-up не сохранился при создании teaser** — Alexandra Ryazantseva
  02.07: GitHub issue #1146 создал. Ждём.
  Issue: https://github.com/maestra-io/issues-maestra/issues/1146
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783010541696629

- [ ] **CF-1603 — marathonbet-eu / drhonow: попап/виджет не активируется, тестовая ссылка не формируется** — Sofia Romanova + Eugenia
  10.07: postgres персо тормозил → выяснили downgrade freight на удалённый EU redis (Kargo сам откатил через Octopus stable-train). Промоучили `1.0.2129`, redis снова in-cluster Dragonfly. Downgrade-guard в Octopus template v10 выкачен. Проверить у клиента.
  Threads: https://maestraio.slack.com/archives/C09M9UEA6BZ/p1783675111508969

- [ ] **CF-1560 — Eugenia natvbasics: правый блок начислений не скроллится** — Eugenia Smirnova
  Скорее всего с крохотного ноута смотрят. GitHub issue #1170 создал.
  Issue: https://github.com/maestra-io/issues-maestra/issues/1170
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783503843735189

- [ ] **Shopify-app: сделать ID блока обязательным** — Артём подтвердил
  Не на мне, проверить когда выкатят.
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1779115929682469

- [ ] **Trashie errors после фиксов** — Alex Glazkov + ClearFeed bot
  Дать ответ — residual ожидаемые или нужны ещё фиксы.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1780920351147619

## Scheduled / future
