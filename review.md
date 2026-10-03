# CF-2541 — разбор перед UPDATE (omega, personalization DB)

**БД:** `db-personalization-omega-us` (PostgreSQL, Teleport app → `tsh proxy app`, Vault role `personalization-omega-us`). Это Django-база popmechanic-backend, таблицы `cabinet_form` / `cabinet_site` / `app_accountmatch`.

**Тенант:** Admitad, `account_id = 5824` (`cabinet_account.is_active = true`).

## Результаты читающих запросов

- **A0 (sanity, весь omega):** per-domain неудалённых форм — только у 5824, все `active=false`, **140 шт.** Других аккаунтов и активных per-domain форм нет.
- **A (preview 5824):** 140 строк, 123 pop-up + 17 inline-block, все с непустыми `endpoints` (`ConvertSocialLandingsPopups` и т.п.). Распределены по 23 сайтам (`store.admitad.com` — 73, остальные ≤9).
- `cabinet_testgroup.site_id` — на omega **ни одной** группы с site_id; ни одна из 140 форм не в test_group.
- Контекст по 5824: 633 неактивных без site, 140 неактивных с site (цель), 249 удалённых (не трогаем).

## Риски и что проверено

- **FK:** `cabinet_form.site_id → cabinet_site(id)`, DEFERRABLE, без каскада на формы. NULL валиден (`is_nullable=YES`, Django `null=True, on_delete=SET_NULL`). Триггеров на `cabinet_form` нет.
- **Флаг `accountHasPerDomainForms`** (`personalization/usecases/account_has_per_domain_forms.py`) считает только `active=True` формы с site → для Admitad уже `False`, UPDATE его не меняет. Пересборка бандла не нужна.
- **Init-кэш / `post_save`-сигнал** (`cabinet/signals/cache.py`) прямым UPDATE обойдётся, но `get_init_data` (`web/usecases/web_settings.py`) берёт только `active=True` формы → неактивные в кэш не входят, инвалидировать нечего.
- **Reversion-история** форм прямым UPDATE не пишется — для неактивных форм приемлемо.
- **Побочный эффект при будущей активации:** форма без site станет per-endpoint; у всех 140 endpoints непустые, «мин» из предупреждения Кирилла нет.
- Файл Кирилла соответствует сути тикета: только SELECT + один UPDATE, один тенант, без DDL.

## Что будет выполнено после «ok»

```sql
BEGIN;
UPDATE cabinet_form
   SET site_id = NULL
 WHERE account_id = 5824
   AND active    = false
   AND site_id IS NOT NULL
   AND deleted   = false;
COMMIT;
```
Ожидаемо: `UPDATE 140`. Затем скрипт 2 (ворота) — ожидаемо пустой результат.
