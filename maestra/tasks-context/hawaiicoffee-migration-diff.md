# hawaiicoffee widget template migration diff

**CF-1407** · старый шаблон `58268` (hawaiicoffee) → новый шаблон `58422` (test-maestra, defaults).
**Thread:** https://maestraio.slack.com/archives/C08FEDXGQUC/p1782324762714079

---

## Ключевые structural изменения (кроме key diff)

1. **`user_tns`** (старый) содержал `responsive` breakpoints с `fixedWith: 200` — теперь через отдельные ключи `fixed_width_card` / `is_fixed_width_card` / `set_widget_width`.
2. **CSS layout** переехал с `grid-row: <%= X_ordering %>` на **`order:` в flexbox** — все `*_ordering` теперь для flex-order, не для grid.
3. **CSS шаблон** новый использует `align-items: end/center` в зависимости от `price_cart_row` — вводит **row-layout для price ↔ cart**.
4. **CSS shadow** теперь с alpha: `<%= card_shadow_color %>40` (был hardcoded `rgba(0,0,0,0.25)`).
5. **Template**:
   - Добавлен блок Shopify currency conversion (`enable_shopify_rates` → `.toLocaleString` через `Shopify.currency.active`).
   - Добавлен loop по `product.labels` (кастомные лейблы кроме discount/new).
   - `alt_image_field` — теперь через переменную-selector, не через хардкод `customFields.altImage`.
   - Обёртки `type="button"` на favorite/cart кнопках.
   - Добавлен `.popmechanic-variants-holder` (dropdown для Shopify variants).
   - `btn_fav_func` / `btn_cart_func` теперь получают `(product, e)`.
6. **`shopId`** старый — client-specific (`"hccid"`), новый — универсальный (`"external-systems"`). Оставить старое значение при миграции (это identity клиента).
7. **User-media host**: старые ассеты на `pw.maestra-static.io`, новые — на `ws.maestra-static.io`. При миграции URL можно **оставить старые** (клиент уже кастомизировал иконки), но если они в дефолтах — новые дефолты в новом.

---

## Fields to ADD при миграции (в новом, нет в старом)

| Field | Default (new) | Group | Комментарий |
|---|---|---|---|
| `labels` | `""` | data | Runtime labels string |
| `widget_width` | `"100"` | widget layout | ширина виджета |
| `widget_width_unit` | `"%"` | widget layout | `%` или `px` |
| `set_widget_width` | `"0"` | widget layout | вкл/выкл ширину |
| `is_fixed_width_card` | `"0"` | widget layout | фикс. ширина карточки |
| `fixed_width_card` | `"250"` | widget layout | значение фикс. ширины |
| `widget_background` | `"#ffffff"` | widget layout | фон виджета |
| `use_widget_background` | `"0"` | widget layout | вкл/выкл фона |
| `center_slider` | `"0"` | slider | центровка slider |
| `bullet_spacing` | `"10"` | slider | зазор bullets |
| `currency_order` | `"-1"` | price | порядок символа валюты (было hardcoded по `hidden_locale`) |
| `currency_padding` | `"0"` | price | column-gap валюты (было `0.5ch` захардкожено) |
| `price_cart_row` | `"0"` | price/cart layout | price+cart в ряд или колонкой |
| `price_cart_order` | `"1"` | price/cart layout | какой первым |
| `card_picture_ordering` | `"1"` | card ordering | order-index картинки |
| `card_variant_ordering` | `"7"` | card ordering | order-index dropdown вариантов |
| `card_aux_html_ordering` | `"6"` | card ordering | order-index aux-блока |
| `card_aux_html_show` | `"0"` | aux html | вкл/выкл aux-блок |
| `card_aux_html_field` | `""` | aux html | какое customField рендерить |
| `card_shadow_color` | `"#000000"` | shadow | цвет тени (был hardcoded) |
| `card_hov_shadow_color` | `"#000000"` | shadow | цвет тени при hover |
| `alt_image_field` | `""` | image | какое customField — hover image (было `altImage` захардкожено в template) |
| `label_font_custom` | `"Circe, Arial, sans-serif"` | fonts | кастомный шрифт labels |
| `label_font_family` | `""` | fonts | fallback font-family для labels |
| `label_font_custom_show` | `"0"` | fonts | вкл/выкл кастом labels |
| `price_font_custom` | `"Circe, sans-serif"` | fonts | кастомный шрифт price |
| `price_font_family` | `"inherit"` | fonts | fallback price |
| `price_font_custom_show` | `"0"` | fonts | вкл/выкл кастом price |
| `product_name_font_custom` | `"Circe, sans-serif"` | fonts | кастомный шрифт name |
| `product_name_font_family` | `"inherit"` | fonts | fallback name |
| `product_name_font_custom_show` | `"0"` | fonts | вкл/выкл кастом name |
| `cart_font_custom` | `"Circe, sans-serif"` | fonts | кастомный шрифт cart |
| `cart_font_family` | `"inherit"` | fonts | fallback cart |
| `cart_font_custom_show` | `"0"` | fonts | вкл/выкл кастом cart |
| `enable_shopify_cart` | `"0"` | shopify | использовать Shopify cart API |
| `enable_shopify_rates` | `"0"` | shopify | конвертация валют через `Shopify.currency` |
| `enable_shopify_variants` | `"0"` | shopify | dropdown вариантов Shopify |
| `enable_shopify_drawer_update` | `"0"` | shopify | обновление cart drawer |
| `minimum_fraction_digits` | `"2"` | shopify | fraction digits для конвертации |

**Итого 39 полей.**

---

## Fields to REMOVE / map при миграции (в старом, нет в новом)

| Old field | Действие |
|---|---|
| `useGa4` | Удалить. GA4 handling переехало в другой tracking layer. |
| `gaMeasurementId` | Удалить (было пусто у клиента всё равно). |
| `priceLocale` | Удалить. Замена — `enable_shopify_rates` + `Shopify.locale` runtime, либо `minimum_fraction_digits`. |
| `probability_mode` | Удалить (deprecated). |
| `btn_cart_ordering` | Удалить. Позиция cart теперь через `price_cart_row` + `price_cart_order` (row layout). |

---

## Значения тех же ключей — заметные отличия

| Key | Old (hccid) | New (default) | Действие |
|---|---|---|---|
| `controls` | `"1"` | `"0"` | оставить старое (клиент включил) |
| `lessCount` | `"2"` | `"0"` | оставить старое |
| `responsive` | `"2.2,10,1;480,2,10,1;768,3,10,1;1280,5,10,1"` | `"1,10,1;480,2,10,1;768,3,10,1;1280,4,10,1"` | оставить старое (клиент подтюнил) |
| `algorithm1` | `{"systemName":"BestSellersAll30days","recoTarget":"Customer"}` | `"reco-algorithms"` | оставить старое |
| `card_prices_col` | `"0"` | `"1"` | оставить старое (row в старом) |
| `card_name_align` | `"left"` | `"center"` | оставить старое |
| `card_prices_align` | `"left"` | `"center"` | оставить старое |
| `card_rating_align` | `"left"` | `"center"` | оставить старое |
| `card_vendor_align` | `"left"` | `"center"` | оставить старое |
| `card_padding_hor` | `0` | `"10"` | оставить старое |
| `card_padding_vert` | `0` | `"10"` | оставить старое |
| `card_border_radius` | `0` | `"8"` | оставить старое (0 = square у клиента) |
| `card_img_border_radius` | `0` | `"8"` | оставить старое |
| `card_img_padding_hor` | `0` | `"10"` | оставить старое |
| `card_img_padding_vert` | `0` | `"10"` | оставить старое |
| `card_img_margin_bottom` | `5` | `"0"` | оставить старое |
| `card_labels_position_hor` | `25` | `"0"` | оставить старое |
| `card_labels_position_vert` | `25` | `"0"` | оставить старое |
| `card_labels_border_radius` | `0` | `"4"` | оставить старое |
| `card_labels_space` | `4` | `"5"` | оставить старое |
| `card_name_fs_desk` | `13` | `"16"` | оставить старое |
| `card_name_fs_mob` | `12` | `"16"` | оставить старое |
| `card_name_lh` | `1.3` | `"1.5"` | оставить старое |
| `card_name_fw` | `"700"` | `"400"` | оставить старое |
| `card_name_color` | `"#181e1e"` | `"#444"` | оставить старое |
| `card_name_margin_bottom` | `7` | `"10"` | оставить старое |
| `card_vendor_fs_desk` | `12` | `"16"` | оставить старое |
| `card_vendor_fs_mob` | `10` | `"16"` | оставить старое |
| `card_vendor_color` | `"#616060"` | `"#444"` | оставить старое |
| `card_vendor_margin_bottom` | `7` | `"10"` | оставить старое |
| `card_vendor_ordering` | `"1"` | `"3"` | ⚠️ **проверить** — старое было grid-row, новое — flex-order. Возможно, нужна переиндексация чтобы сохранить визуальный порядок. |
| `card_name_ordering` | `"2"` | `"2"` | нейтрально |
| `card_prices_ordering` | `"3"` | `"5"` | ⚠️ **проверить** — same. |
| `card_rating_ordering` | `"4"` | `"4"` | нейтрально |
| `card_rating_customfield` | `"avgRating"` | `"rating"` | ⚠️ **оставить старое** (клиентское поле). |
| `card_rating_img_size_desk` | `14` | `"18"` | оставить старое |
| `card_rating_img_size_mob` | `13` | `"18"` | оставить старое |
| `card_rating_margin_bottom` | `0` | `"10"` | оставить старое |
| `card_prices_color` | `"#e95144"` | `"#444"` | оставить старое |
| `card_prices_fs_desk` | `14` | `"15"` | оставить старое |
| `card_prices_fs_mob` | `12` | `"15"` | оставить старое |
| `card_prices_margin_bottom` | `5` | `"10"` | оставить старое |
| `card_price_discount_color` | `"#181e1e"` | `"#999"` | оставить старое |
| `card_label_discount_bg` | `"#e95144"` | `"#f03e3e"` | оставить старое |
| `card_label_discount_border` | `"#e95144"` | `"#f03e3e"` | оставить старое |
| `card_label_discount_color` | `"#fcfcfc"` | `"#fff"` | оставить старое |
| `header` | `"Best Sellers"` | `"BEST SELLERS"` | оставить старое |
| `header_fz_desk` | `21` | `"26"` | оставить старое |
| `header_margin_bottom` | `10` | `"20"` | оставить старое |
| `main_padding_vert` | `28` | `"30"` | оставить старое |
| `slider_show_bullit` | `"0"` | `"1"` | оставить старое |
| `btn_cart_show` | `"0"` | `"1"` | оставить старое (у клиента cart скрыт) |
| `btn_fav_show` | `"0"` | `"1"` | оставить старое |
| `btn_cart_func` | `"maestraAddToCart(product.productGroup.ids.bigCommerceID)"` | `"addToCart(product.ids.mindboxId ...)"` | ⚠️ **оставить старое** (BigCommerce integration). |
| `endpoint` | `"endpoints"` | `"endpoints"` | нейтрально |
| `recommendationLimit` | `"10"` | `"12"` | оставить старое |
| `recommendationLimit2` | `"12"` | `"12"` | нейтрально |
| `hidden_locale` | `"en"` | `"en"` | нейтрально |
| `font_custom` | `'"Noto Sans", Arial, Helvetica, sans-serif'` | `"Circe, Arial, sans-serif"` | оставить старое |
| `font_custom_show` | `"1"` | `"0"` | оставить старое |

---

## План миграции (для агента в бэкенде)

1. **Копирование:** взять существующие значения виджета старого шаблона.
2. **Добавить 39 новых полей** с дефолтами (см. таблицу выше).
3. **Удалить 5 устаревших** полей.
4. **Заменить `css` и `template`** на новые (они драйверят структуру).
5. **Пересчитать `*_ordering`** — старые значения были для `grid-row`, теперь для flex `order`. Логика "1..N сверху вниз" сохраняется, но нужно убедиться что новые полей (picture=1, variant=7, aux_html=6) не конфликтуют с существующими user-values.
6. **Проверить `card_rating_customfield`** — у hccid `avgRating`, у нового дефолта `rating`. Оставить старое.
7. **`btn_cart_func`** — оставить BigCommerce-версию клиента, НЕ перезаписывать новым дефолтом.
8. **User-media assets** (`btn_fav_img_*`, `card_rating_img_*`, `slider_button_icon_*`, `btn_cart_icon_src`) — оставить клиентские URL с `pw.maestra-static.io`, НЕ подменять на `ws.maestra-static.io` дефолты.

---

## Открытые вопросы

1. Как ведёт себя миграция когда старый `*_ordering` был `grid-row`, а новый CSS их использует как `order`? Нужно тестирование на реальном виджете hccid.
2. `card_vendor_ordering` (1 → 3) и `card_prices_ordering` (3 → 5) — это по факту одинаковый визуальный порядок (vendor выше prices), но абсолютные значения разные. Скорее всего оставить старые OK, но проверить.
3. `card_rating_customfield` — у hccid `avgRating`, у test-maestra `rating`. Оба поля существуют? Или у hccid `rating` пустой? Не пересобирать client_media без нужды.
