# Reco widget dedup + load priority

**Ticket:** CF-672 (reopened by Julia Lo 2026-06-29)
**Thread:** https://maestraio.slack.com/archives/C08FEDXGQUC/p1773338878182269
**Repo:** `~/projects/mindbox/popmechanic-client` (runtime widget engine на клиенте)

## Проблема

В reopen-сообщении Julia описала **два разных случая** одного root cause — глобальный singleton dedup-cache между reco-виджетами на странице:

### Case A — Often Bought With priority (исходный CF-672)
- Widget A (dedup=on) грузится РАНЬШЕ widget B "Often Bought With".
- A первый `store()`-ит свои items в глобальный cache.
- B через `filter()` теряет свои items → OBW пустеет / показывает не то.
- **Хочется:** OBW имел приоритет; widget A ждал/фильтровал ПОСЛЕ OBW.

### Case B — Sena widget «загружается но не показывается»
- Widget Sena `https://sena.maestra.io/personalization/reco-widget/52707` должен показываться **только если другого reco нет** на странице.
- Технически Sena всё равно fetch'ится → items уходят в global cache → соседние reco теряют эти items через dedup.
- «Наоборот» от case A: dedup выбрасывает продукты из соседей, ссылаясь на widget которого не видно.

## Root cause (по коду)

`ProductListRepeatsFilter` — **singleton** на всю страницу, shared across всех `RecoDataBehavior` инстансов.

Ключевые точки:
- `src/js/view/behavior/RecoDataBehavior/RecoDataBehavior.ts:28` — `const productListRepeatsFilter = new ProductListRepeatsFilter()` (singleton).
- `src/js/view/behavior/RecoDataBehavior/RecoDataBehavior.ts:253-261` — в `handleSuccess()` вызываются `filter()` и `store()`. **`store()` вызывается безусловно** для любого виджета, который дошёл до fetch — независимо от того, будет ли он реально виден.
- `src/js/view/behavior/RecoDataBehavior/helpers/ProductListRepeatsFilter.ts:4,33,43-44` — global cache, `filter()` смотрит только location/cache state, не visibility соседних виджетов.

## Load flow (по факту, не по мнению)

- `src/js/models/Init/Init.ts:196-254` — orchestration. Forms инициализируются chunks по 10 через `rafMap`. Targeting checks sequentially. НО каждый onTargetingChange запускает view creation через `queueMicrotask` → эффективно **параллельно**.
- `src/js/view/FormView.ts:76,88` — targeting evaluation ↔ `behaviorsOnBeforeRender()`.
  - ⚠️ **Расхождение между двумя research-агентами**: один сказал targeting проверяется ПОСЛЕ `onBeforeRender()` (:88), другой — ДО (:76). **Перечитать самому** прежде чем править — от этого зависит правильный дизайн фикса.
- `src/js/view/behavior/RecoDataBehavior/RecoDataBehavior.ts:113-170,195` — fetch виджетов через `Promise.all` → параллельно, порядок определяется гонкой DOM traversal + targeting timing.
- `src/js/view/viewFactory.ts` + `src/js/view/FormView.ts:42-90` — view creation / targeting gate.

## Гонка в двух словах

```
[Widget A: dedup=on]      [Widget B: OBW]         [Widget C: Sena, targeting=hidden]
       │                         │                         │
       ├─fetch─┐                 ├─fetch─┐                 ├─fetch─┐
       │      ▼                  │      ▼                  │      ▼
       │  handleSuccess          │  handleSuccess          │  handleSuccess
       │      │                  │      │                  │      │
       │  store(items) ────►[global cache: A_items + C_items ← и Sena сюда попадает!]
       │                         │      │
       │                         │  filter(against cache) → выбрасывает A_items, C_items
       │                         │      │
       │                         │  → в B пропадают Sena-items хотя Sena не показывается
       ▼                         ▼                         (variantShow: isInTargeting=false → return)
```

Ключевая утечка: **store() безусловный, targeting-visibility gate только в viewShow, применяется ПОСЛЕ**.

## Feasibility фикса

| Подход | Сложность | Ломает | Комментарий |
|---|---|---|---|
| **#1** Gate `store()` (и, возможно, `filter()`) на `form.inTargeting` | Низкая | Мин. | Одна проверка в `handleSuccess` перед `store()`. Ловит Case B (Sena) сразу. |
| **#2** Sort виджетов по `priority` в `Init.ts:252` до `rafMap(checkTargeting)` | Средняя | Низкая | Добавить `priority: number` в `FormData`. High-prio первыми доходят до `store()`. Ловит Case A (OBW). |
| **#3** Sequential fetch по priority в `RecoDataBehavior` (lock/queue) | Средняя | Низкая | Альтернатива #2, но с queue поверх `Promise.all`. |
| **#4** Defer low-priority view creation (async queue в forms.ts) | Высокая | Средняя | Overkill. |

**Рекомендация:** #1 + #2 = 80% пользы при 20% усилий.

## Что нужно ещё выяснить перед PR

1. **Порядок `variantShow` vs `onBeforeRender`** — резольвнуть разногласие агентов, точно понять когда `isInTargeting()` проверяется относительно `store()`.
2. Есть ли у форм понятие **reactive targeting** (может ли targeting поменяться после `onBeforeRender`) — если да, gate на статичное значение может пропускать edge cases.
3. Как в **legacy формах** без нового `priority` дефолтить (0? или sortOrder из DOM?) — backward compat.
4. Performance: sequential по priority может увеличить perceived latency. Стоит ли ограничить sequencing только между приоритетами (same-priority параллельно).

## Как ответить Julia (Slack)

Case B — баг, не дизайн. Case A — фича (нужна priority). Оба фиксятся одним ходом:
- добавляем опциональный `priority` в form settings;
- `store()` gate на «widget in targeting AND will render»;
- виджеты с явным priority сортируются первыми в fetch queue.

Оценить эффорт после фикса разногласия по FormView.

## Related tickets / контекст

- CF-672 (2026-03-12 original, 2026-06-29 reopen): https://maestraio.slack.com/archives/C08FEDXGQUC/p1773338878182269
- Первое обсуждение priority (2026-03-18): Gleb → «Right now no loading priority, yet it's one more case to prioritize it higher».

## Files to touch (для агента в popmechanic-client)

Приоритет:
1. `src/js/view/behavior/RecoDataBehavior/RecoDataBehavior.ts` (handleSuccess :253-261, onBeforeRender :113-170)
2. `src/js/view/behavior/RecoDataBehavior/helpers/ProductListRepeatsFilter.ts` (store/filter API)
3. `src/js/view/FormView.ts` (:76,88 — уточнить порядок; возможно передавать targeting в behavior)
4. `src/js/models/Init/Init.ts` (:196-254 — priority sort)
5. `src/js/models/Form/*` (`FormData` type — добавить `priority?: number`)
6. `src/js/view/viewFactory.ts`
