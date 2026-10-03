# CF-2541 — run log (omega, 2026-10-01)

БД: `db-personalization-omega-us` (PostgreSQL), Vault role для UPDATE — `db-owner-personalization-omega-us`
(writer-роль для токена закрыта 403). Подтверждение юзера на UPDATE получено в триаже.

## Скрипт 1 (A0) — sanity по всему omega, до UPDATE
```sql
SELECT cf.account_id, am.mindbox_system_name, cf.active, count(*) AS forms
FROM cabinet_form cf
LEFT JOIN app_accountmatch am ON am.account_id = cf.account_id AND am.is_staging = false
WHERE cf.site_id IS NOT NULL AND cf.deleted = false
GROUP BY cf.account_id, am.mindbox_system_name, cf.active
ORDER BY forms DESC;
```
```
 account_id │ mindbox_system_name │ active │ forms
       5824 │ Admitad             │ f      │   140
(1 row)
```

## Скрипт 1 (A) — preview 5824, до UPDATE
```sql
SELECT cf.id, cf.name, cf.site_id, af.endpoints
FROM cabinet_form cf
LEFT JOIN app_formproxy af ON af.form_id = cf.id
WHERE cf.account_id = 5824
  AND cf.active = false
  AND cf.site_id IS NOT NULL
  AND cf.deleted = false
ORDER BY cf.id;
```
140 строк (123 pop-up, 17 inline-block), все endpoints непустые. Полный CSV: `preview-a.csv`.

## Состояние 5824 до UPDATE
```
 active │ deleted │ has_site │ count
 f      │ f       │ f        │   633
 f      │ f       │ t        │   140   <- цель
 f      │ t       │ f        │   208
 f      │ t       │ t        │    41
 t      │ t       │ f        │     2
 t      │ t       │ t        │     1
```

## Скрипт 1 (B) — APPLY
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
Выполнен в одной транзакции, COMMIT. Затронуто 140 строк (подтверждено пост-проверкой ниже).

## Скрипт 2 — ворота, после UPDATE
```sql
SELECT cf.account_id, am.mindbox_system_name, cf.active,
       count(*)                        AS forms,
       array_agg(cf.id ORDER BY cf.id) AS form_ids
FROM cabinet_form cf
LEFT JOIN app_accountmatch am ON am.account_id = cf.account_id AND am.is_staging = false
WHERE cf.site_id IS NOT NULL
  AND cf.deleted = false
GROUP BY cf.account_id, am.mindbox_system_name, cf.active
ORDER BY forms DESC;
```
```
 account_id │ mindbox_system_name │ active │ forms │ form_ids 
────────────┼─────────────────────┼────────┼───────┼──────────
(0 rows)
```
PASS — пустой результат.

## Состояние 5824 после UPDATE
```
 active │ deleted │ has_site │ count 
────────┼─────────┼──────────┼───────
 f      │ f       │ f        │   773
 f      │ t       │ f        │   208
 f      │ t       │ t        │    41
 t      │ t       │ f        │     2
 t      │ t       │ t        │     1
(5 rows)
```
633 + 140 = 773 неудалённых без site, с site — 0. Удалённые формы (41 с site) не трогались по условию.
