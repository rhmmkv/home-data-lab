#!/usr/bin/env bash
# Загрузка REES46 Electronics для Home Data Lab v0.3.0.
# Запускать на сервере из каталога с Compose-файлом PostgreSQL:
#   bash scripts/import_rees46.sh
# Создаёт схему rees46 и таблицу rees46.events, загружает events.csv через COPY,
# затем сверяет показатели с исходным CSV.
# Если схема rees46 уже есть, создание завершится ошибкой и загрузки не будет,
# поэтому повторный запуск не задвоит строки.

set -euo pipefail

csv_file='/srv/data/datasets/rees46-electronics/csv/events.csv'
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
create_sql="${script_dir}/../sql/rees46/01_create_tables.sql"
verify_sql="${script_dir}/../sql/rees46/02_verify_import.sql"

# Проверить все входные файлы до изменения базы.
for path in "$csv_file" "$create_sql" "$verify_sql"; do
    if [[ ! -r "$path" ]]; then
        printf 'Cannot read input file: %s\n' "$path" >&2
        exit 1
    fi
done

# Запросить пароль sudo до передачи файлов в стандартный ввод psql.
sudo -v

run_psql() {
    sudo docker compose exec -T database \
        psql -X -v ON_ERROR_STOP=1 -P pager=off \
        -U lab_admin -d home_data_lab "$@"
}

printf 'Creating schema rees46 and table rees46.events\n'
run_psql < "$create_sql"

# Оболочка открывает CSV на сервере, Docker передаёт поток psql в контейнере.
printf '\nLoading %s -> rees46.events\n' "$csv_file"
run_psql -c \
    "COPY rees46.events FROM STDIN WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');" \
    < "$csv_file"

printf '\nImport check: actual versus expected from the original CSV\n'
run_psql < "$verify_sql"
