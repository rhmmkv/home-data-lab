# Данные

В репозитории два набора: Olist (версии 0.1–0.2) и REES46 Electronics (версия 0.3). Исходные файлы в Git не входят; [sources.json](sources.json) содержит ссылки на источники, SHA-256 архивов и CSV, размеры, число строк и заголовки.

## Olist

Источник — [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). Анализ использует девять CSV без преобразования исходных файлов.

| Таблица | Строк |
|---|---:|
| `customers` | 99 441 |
| `geolocation` | 1 000 163 |
| `order_items` | 112 650 |
| `order_payments` | 103 886 |
| `order_reviews` | 99 224 |
| `orders` | 99 441 |
| `products` | 32 951 |
| `sellers` | 3 095 |
| `product_category_name_translation` | 71 |

Даты оформления заказов в `orders`: с 4 сентября 2016 года по 17 октября 2018 года. Полнота представления бизнеса за этот период не установлена; особенности покрытия описаны в [проверках данных](../analysis/olist/data_quality.md).

### Состав и целостность

[sources.json](sources.json) содержит ссылку на источник, SHA-256 архива и каждого CSV, размер, число строк и заголовки столбцов. Пути относительны корню репозитория и описывают размещение после скачивания; сами файлы в Git не включены.

Архив распакован без преобразований. Количества строк в PostgreSQL сверены с CSV через [SQL 02](../sql/olist/02_verify_counts.sql). Это проверка импорта, а не полная проверка всех ключей и связей.

### Загрузка

1. Скачать набор со страницы источника и ознакомиться с указанными там условиями использования.
2. Распаковать CSV в `data/raw/olist/csv/` для локального хранения либо в каталог импорта на сервере.
3. Подготовить таблицы через [SQL 01](../sql/olist/01_create_tables.sql).
4. Загрузить CSV с помощью [скрипта импорта](../scripts/import_olist.sh) и сверить количества строк.

В конфигурации лаборатории скрипт читает `/srv/data/datasets/olist/csv`. [Полная инструкция](../docs/reproduce.md) описывает необходимые роли, базу и параметры среды.

## REES46 Electronics

Источник — [eCommerce events history in electronics store](https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-electronics-store). Используется один файл `events.csv` без преобразований: 885 129 событий (`view` — 793 748, `cart` — 54 035, `purchase` — 37 346), 407 283 пользователя. Время событий в файле — с 24.09.2020 11:57 до 28.02.2021 23:59 UTC; этот период отличается от указанного в описании набора.

Столбцы: `event_time, event_type, product_id, category_id, category_code, brand, price, user_id, user_session`. Пустые значения: `category_code` — 236 219, `brand` — 212 364, `user_session` — 165.

### Загрузка

1. Скачать набор со страницы источника и ознакомиться с условиями использования.
2. Распаковать `events.csv` в `data/raw/rees46-electronics/csv/` либо в каталог импорта на сервере (в лаборатории — `/srv/data/datasets/rees46-electronics/csv`).
3. Выполнить [скрипт импорта](../scripts/import_rees46.sh): он создаёт таблицу ([SQL 01](../sql/rees46/01_create_tables.sql)), загружает CSV через `COPY` и сверяет 11 показателей с исходным файлом ([SQL 02](../sql/rees46/02_verify_import.sql)).

Для дашборда страницы 1 тот же `events.csv` загружается в Power BI Desktop файлом.
