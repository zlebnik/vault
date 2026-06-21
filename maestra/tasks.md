---
_favorite: true
_favorite_index: 2
_organized: true
---
# Maestra — Tasks

## Active — my move

- [x] **DM Sasha Haishun — clarity tagging lectric: разделить FBT vs recently viewed (mobile/desktop)** — Aliaksandr
  Закрыто.
  DM: https://maestraio.slack.com/archives/D09LNLKC4TZ/p1781790378259909

- [ ] **⚠️ #product-support CF-1274 — Julia Lo: optimize images default ON** _(overdue +4d, обещал 15.06)_ — Julia Lo
  #1 для product reco widgets сделать «optimize images» включённым по умолчанию. #2 Copenhagen — проблема в фиде.
  Widget: https://copenhagenliving.maestra.io/personalization/reco-widget/58009
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781292825885029

- [ ] **CF-1363 — Julia Lo: client-side cache/SW issue (другой браузер работает)** — Julia Lo
  **RCA:** Backend, JS chunks, features, permissions, brand — **идентичны** у Julia и Gleb. createNew POST к `scenarios.maestra.io/scenario/<folderId>/createNew` не запускается только в её основном браузере (в другом браузере — работает). Значит local state issue: Apollo cache / localStorage / SW / cookies.
  **Связь с Datadog spike:** возможно несколько CSM имеют тот же baked client state; spike NullRenderError 9 events 14:00–15:00 UTC.
  **Workaround Julia:** clear site data + hard reload, либо другой браузер.
  **Open:** надо ли в коде ProactiveClearOnVersionMismatch / proper migration. Эскалировать `frontend_scenarios_v2` команде если повторится у других.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781883863645459

- [ ] **Banner carousel: полноценный UI для Swiper settings** _(CF-1020 auto-closed, effort card создан, в pipeline)_ — Julia Lo
  ClearFeed auto-closed после 3 недель. Effort card в Notion. Делать сам dev-work.
  Notion: https://www.notion.so/364e0880507881398261fcf9e23f04a9
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1778625361282019

- [x] **DM Danil — MR 6568 + конструктор персо + AB + phone_confirmation формы** — Danil
  Порешали.
  MR: https://mindbox.gitlab.yandexcloud.net/development/frontend/frontend-mailings/-/merge_requests/6568
  DM: https://maestraio.slack.com/archives/D08Q20UUWUD/p1781092780330059

- [x] **DM Ruslan Temirgaliev — приёмка, что принимать (email/sms)?** — Ruslan
  Закрыто.
  DM: https://maestraio.slack.com/archives/D09JPAPEDPC/p1781017074403109

## Waiting on others

- [ ] **CF-1315 zone3 reco — жду от Eugenia конкретный девайс** — Eugenia
  Карточка слева уходит за экран, плавающий баг на Android. Локально не воспроизвёл, спросил какой именно девайс.
  Widget: https://zone3.maestra.io/personalization/reco-widget/55349
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781675187671859

- [ ] **Julia P. website-loading-speed — ответил на оба вопроса, жду apply** — Julia Pogrebnaia
  Ответил: (1) point «Clean up unused campaigns» ok & sufficient; (2) можно добавить troubleshooting «remove unused third-party scripts». Жду пока Julia применит.
  Thread: https://maestraio.slack.com/archives/C0A36LV9XEG/p1781208923839669

- [ ] **lucyandyak кнопка мигает: отписался Ане, жду подтверждения** — Anna Stepanova
  Убрал всё моргание, осталась небольшая задержка появления кнопки на недоступных вариантах.
  Loom: https://www.loom.com/share/75c1151aae184acdbdfe84b74792b456
  Thread: https://maestraio.slack.com/archives/C09M9UEA6BZ/p1781533869277449

- [ ] **#csm-support — Julia Lo backend-update widgets со старого темплейта на новый** — Julia Lo
  Gleb: «I'll handle the rest, you clone old ones». Жду пока Julia клонирует — потом мигрирую.
  Widget example: https://hawaiicoffee.maestra.io/personalization/reco-widget/54309
  Thread: https://maestraio.slack.com/archives/C089G0JMXJP/p1781719637466469

- [ ] **Selkirk: 5-product carousel cards (CF-1120) — prototype отдан клиенту** — Philipp + Sasha Haishun
  Сделал prototype на selkirkcom widget #58101, отдал Phil/клиенту 17.06. Ждём feedback.
  Prototype: https://selkirkcom.maestra.io/personalization/reco-widget/58101
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1779822892936139

- [ ] **Popup-вёрстка-skill ownership** — Roman + Phil
  Roman: «не хочу, чтобы ты был ответственным. CSM сами драйвят. Найдут и анонсируют».
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1781195064381849

## To verify

- [ ] **Shopify-app: сделать ID блока обязательным** — Артём подтвердил
  Не на мне, проверить когда выкатят.
  Thread: https://maestraio.slack.com/archives/C07KUJQHG93/p1779115929682469

- [ ] **Trashie errors после фиксов** — Alex Glazkov + ClearFeed bot
  Дать ответ — residual ожидаемые или нужны ещё фиксы.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1780920351147619

## Scheduled / future

- [ ] **2026-06-23 — ⚠️ общий фикс квизов везде (CF-1314)** — Phil + Brenden
  ILL quiz сдох 17.06, чинил вручную через popmechanic-client MR 889. Phil: «Бренден говорит, у него не работает. У меня — до сих пор не работает». Нужен общий фикс чтоб везде заработало.
  Thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781663939494119

- [ ] **до 26.06 — занести «add-to-cart JS-код» в продукт целиком** — Anna Stepanova + всё больше клиентов
  Обещал «до конца следующей недели в продукт занесём целиком».
  Last thread: https://maestraio.slack.com/archives/C08FEDXGQUC/p1781710943353579
