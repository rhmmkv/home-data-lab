# Metabase

Metabase Open Source представляет результаты анализа PostgreSQL в виде карточек, графика и таблицы. [Дашборд и инструкция сборки](../../analysis/olist/dashboard.md).

## Условия запуска

- Действующий PostgreSQL доступен как сервис `database:5432` в Docker-сети `home-data-lab_default`.
- Созданы роль `metabase_app` с паролем и одноимённая база с этим владельцем. Это служебная база настроек Metabase.
- Источник анализа — отдельная база `home_data_lab`, схема `olist`; роль `analyst` имеет права чтения.
- Порт `127.0.0.1:3000` сервера свободен.

Compose-проект `home-data-lab-bi` подключается к существующей внешней сети PostgreSQL. При других именах сервиса или сети адаптировать [compose.yaml](compose.yaml).

## Запуск

Поместить `compose.yaml` и `.env.example` в отдельный каталог на сервере. Создать рядом локальный `.env` по образцу `.env.example`, указать пароль роли `metabase_app` и ограничить чтение файла:

```bash
cp .env.example .env
# Указать свой пароль в .env перед запуском.
chmod 600 .env

sudo docker compose --env-file .env -f compose.yaml config --quiet
sudo docker compose --env-file .env -f compose.yaml up -d
sudo docker compose --env-file .env -f compose.yaml ps
```

`config --quiet` проверяет конфигурацию без вывода подставленного пароля. Переходить к запуску после успешной проверки. Состояние `healthy` ожидается после инициализации служебных таблиц.

## Доступ и источник данных

Порт Metabase опубликован только на loopback-адресе сервера. С рабочего компьютера открыть SSH-туннель, заменив `user@server` своим SSH-адресом:

```bash
ssh -o ExitOnForwardFailure=yes -N \
  -L 3000:127.0.0.1:3000 user@server
```

Пока туннель открыт, интерфейс доступен по адресу `http://localhost:3000`. Создать учётную запись администратора Metabase и добавить PostgreSQL-источник:

| Параметр | Значение |
|---|---|
| Host | `database` |
| Port | `5432` |
| Database | `home_data_lab` |
| User | `analyst` |
| Schema | `olist` |

Пароль — от роли чтения в своей среде. Дополнительный SSH-туннель в настройках источника Metabase не нужен: соединение с PostgreSQL проходит внутри Docker-сети. Для проверки выполнить `SELECT COUNT(*) FROM olist.orders;`, ожидается 99 441.

Затем создать вопросы и дашборд по [инструкции](../../analysis/olist/dashboard.md).

## Хранение и версия

Закреплён образ `metabase/metabase:v0.65.3.3`. Сохранённые вопросы, пользователи и настройки находятся в `metabase_app`. Для восстановления экземпляра нужна резервная копия этой базы и совместимая версия Metabase. Дамп служебной базы в репозиторий не входит.

Пароли задаются через локальный `.env`, исключённый из Git. Проверку конфигурации выполнять с `--quiet`, чтобы не выводить подставленные значения.

Официальная документация: [Docker](https://www.metabase.com/docs/latest/installation-and-operation/running-metabase-on-docker), [служебная база](https://www.metabase.com/docs/latest/installation-and-operation/configuring-application-database).
