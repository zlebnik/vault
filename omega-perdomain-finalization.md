# Omega: финализация отрыва per-domain (тенант Admitad, account_id=5824)

Контекст: на omega единственный аккаунт с per-domain формами — Admitad (5824), все НЕактивные
(0 запущенных). Занулить их `site_id` и подтвердить, что неудалённых per-domain форм не осталось.

⚠️ `cabinet_form.deleted` — BOOLEAN (`true`=удалена). «Не удалена» = `deleted = false` (НЕ `IS NULL`).
⚠️ Скрипт 1 трогает ТОЛЬКО `active=false`. Если вдруг всплывёт `active=true` per-domain — СТОП, такие
обнуляются только тулом `perdomain-apply.py` (обнуление активной флипает флаг accountHasPerDomainForms и
требует пере-сборки бандла — прямым UPDATE нельзя).

## Скрипт 1 — точечное зануление (Admitad 5824)
```sql
-- (A0) SANITY: есть ли на omega per-domain формы НЕ у 5824 или АКТИВНЫЕ?
--      Ожидаемо: только account_id=5824, active=false. Иначе — см. предупреждения выше.
SELECT cf.account_id, am.mindbox_system_name, cf.active, count(*) AS forms
FROM cabinet_form cf
LEFT JOIN app_accountmatch am ON am.account_id = cf.account_id AND am.is_staging = false
WHERE cf.site_id IS NOT NULL AND cf.deleted = false
GROUP BY cf.account_id, am.mindbox_system_name, cf.active
ORDER BY forms DESC;

-- (A) PREVIEW по 5824 (endpoints для контроля; пустой endpoints — потенциальная мина при будущей
--     активации, такие формы лучше не активировать без endpoint):
SELECT cf.id, cf.name, cf.site_id, af.endpoints
FROM cabinet_form cf
LEFT JOIN app_formproxy af ON af.form_id = cf.id
WHERE cf.account_id = 5824
  AND cf.active = false
  AND cf.site_id IS NOT NULL
  AND cf.deleted = false
ORDER BY cf.id;

-- (B) APPLY (в транзакции, «душные» условия — только неактивные неудалённые per-domain формы Admitad):
BEGIN;
UPDATE cabinet_form
   SET site_id = NULL
 WHERE account_id = 5824
   AND active    = false
   AND site_id IS NOT NULL
   AND deleted   = false;
-- сверь число затронутых строк с PREVIEW (A), затем:
COMMIT;   -- или ROLLBACK;
```

## Скрипт 2 — проверка всего окружения (ворота)
```sql
-- PASS = ПУСТОЙ результат: на omega не осталось НЕудалённых форм с проставленным site_id (любой account/active).
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

Вернуть: число строк из UPDATE (скрипт 1, B) + результат скрипта 2 (должен быть пуст).
