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

- [ ] **CF-1650 — bulk backfill container_id (относится к CF-1268)** — Roman + team
  15.07 open. Продолжение CF-1268: попросили запустить бэкфил поля container_id.

- [ ] **Phil UX card: лиды формы по клику из отчёта** — Philipp Volnov
  16.07: Phil завёл карточку, спрашивает делается ли в два счета. Gleb: «по идее можно фильтр ебнуть, вроде изян». Оценить эффорт.
  Notion: https://app.notion.com/p/39ee08805078815f9acedd34eefd7e2c
  Thread: https://maestraio.slack.com/archives/C07KJ72STNW/p1784159203942499

- [ ] **CF-1668 — deako popup verification code: контакт в базе → код не проходит (похоже CF-1428)** — Phil + Артём
  16.07: Phil ввожу код — не работает. Артём: «может контакт уже в базе». Phil подтвердил: удалить телефон → работает. Похоже такой же кейс как CF-1428 lead-gen popup dup phone.
  Popup: https://deako.maestra.io/personalization/pop-up/59673/settings
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1784214427144459

- [ ] **CF-1651 reopened — bug: не работает добавление продукта / обновление корзины (desktop + mobile)** — TBD
  Был закрыт 15.07 как done, но CF вернул в pending 16.07. Разобраться что не так.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1784108286481209

- [ ] **CF-1653 — myflowers quiz становился, «просто выключился модуль»** — Anna Stepanova _(prio high)_
  Repro: https://myflowers.maestra.io/quizzes/quiz/ff966298-5258-4f85-9801-88f8a2881263?tab=Settings
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1784113996220559

- [ ] **CF-1673 — Angel: вернуть «unlimited» sending interval option** — TBD
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1784242719065189

- [ ] **Phil inapp: кнопка Upload image в кастомном HTML** — Philipp + Артём
  17.07: Phil просит кнопку Upload image (как в HTML-редакторе писем) в inapps с кастомным HTML. Артём собрал задачу в Notion, ждёт от Gleb: сложно / изян. Обсудить где хранить картинки + как вставлять по указателю.
  Notion: https://app.notion.com/p/3a3e08805078812f810af278c3ef2026
  Thread: https://maestraio.slack.com/archives/C07KJ72STNW/p1784299413074049

- [ ] **Retro Final Edition (Sergey): встреча про разбор саппорта персо** — Sergey Neudachin + Gleb
  16.07: Sergey в ретро выдал action: «Gleb заведёт встречу про разбор саппорта персо, возьмёт Серёгу на прокачку формата».
  Miro: https://miro.com/app/board/uXjVISpu5Fg=/
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1784201544790939

- [ ] **selkirkcom / SvahaUSA: clear cart after CheckoutCompleted (pixel fix)** — Alex Glazkov
  13.07: Price Drop email на уже купленный товар. Alex: cart не очищается после checkout из-за async processing. Клиент репортит несколько раз в неделю. Alex просит quick fix в pixel logic — на trigger «Checkout completed» вызывать «Update cart» для очистки. Alex: «may be more interesting than I thought», продолжает копать.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1783944702245289

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

- [ ] **CF-1691 — lucyandyak: неизвестная операция `!SdkMethod` в integration-logs** — Anna + Alex Glazkov
  20.07: Alex пинганул. Gleb ответил «он вообще не должен дёргаться, странное, заведу баг». Issue #1195 создан. Ждём фикс.
  Issue: https://github.com/maestra-io/issues-maestra/issues/1195
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1784541074775759

## Scheduled / future
