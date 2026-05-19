# Maestra — Tasks

## Active — my move

- [ ] **Performance analysis для help-статьи** _(due today)_ — Julia Lo + Julia Pogrebnaia
  Quick analysis: цифры по page speed impact от Maestra. Отдать Julia P для оформления в help-статью.
  Thread: https://maestraio.slack.com/archives/C0A36LV9XEG/p1778772184804499

- [ ] **natvbasics custom pop-up — добавить передачу страны по IP** — Eugenia (CF-1066)
  Кастомный поп-ап с 4 экранами, интеграция стандартная shopify, без multi-field. Eugenia дала копию, чтобы не ломать боевой. Глеб обещал «свои лапы в верстку запустить».
  Copy: https://natvbasics.maestra.io/personalization/pop-up/57519
  Live: https://natvbasics.maestra.io/personalization/pop-up/56873
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1779174559077259

- [ ] **Создать шаблон в персо для Ekaterina** — Ekaterina (top-secret-devs)
  Ekaterina исследует виджеты персонализации. Глеб обещал «ща бахну» шаблон. Пока что инлайн-блок с заполнением контактов как fallback.
  Issue: https://github.com/maestra-io/issues-maestra/issues/889
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1779115929682469

- [ ] **Shopify-app: сделать ID блока обязательным** — Артём подтвердил
  В Shopify-секции с SMS подпиской ID блока должен быть обязательным полем. Без фичи fallback по ID → одна операция / другая.
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1779115929682469

- [ ] **Popup multi-fields: проверить старый вариант интеграции** — Артём, Данил
  Шаблоны на стейдже (новые). Спросил Артёма «старый не тыкал?» — ответа нет. Либо самому проверить, либо пнуть.
  Staging: https://hot-1007-mr-674487.testing-env.mindbox.ru/personalization/pop-up/76172
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1778775073592429

- [ ] **Dorai bundle widget — обновить код**
  Доступ к проекту получен. Обновить код под `window.cart.updateCart()` и подписку на `dorai:cart-updated`. Проверить, что `window.cart` теперь доступен на проде.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1771344864478479

## Waiting on others

_(empty)_

## To verify

- [x] **AI markdown fix (Phrase translations)** — проверить на проде
  Фикс CF-1012 через Phrase, должен был быть live в понедельник 2026-05-18.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1778533922379949

## Scheduled / future

- [ ] **2026-05-20 — SEO key points для help-статьи** — Julia Lo + Julia Pogrebnaia
  Несколько key thoughts по impact фронтенд-инъекций Maestra на SEO. Отдать Julia P для оформления в help-статью.
  Thread: https://maestraio.slack.com/archives/C0A36LV9XEG/p1778772184804499

- [ ] **2026-05-21 — Banner carousel: полноценный UI для Swiper settings** — Julia Lo (Svaha memorial day)
  Когда дойдут руки — делаем сразу полноценный UI (slider on/off, loop, center, items per view) per device, без промежуточного code-only extension point.
  Effort Notion: https://www.notion.so/364e0880507881398261fcf9e23f04a9
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1778625361282019
