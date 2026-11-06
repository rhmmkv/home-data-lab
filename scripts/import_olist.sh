#!/usr/bin/env bash
# Initial Olist import. Run on the server from ~/compose-pg-lab:
# bash scripts/import_olist.sh
# Each COPY is a separate transaction. Completed tables stay loaded if a
# later file fails. The empty-table check prevents duplicating those rows.

set -euo pipefail

csv_root='/srv/data/datasets/olist/csv'
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
verify_sql="${script_dir}/../sql/olist/02_verify_counts.sql"

tables=(
    customers
    geolocation
    order_items
    order_payments
    order_reviews
    orders
    products
    sellers
    product_category_name_translation
)

files=(
    olist_customers_dataset.csv
    olist_geolocation_dataset.csv
    olist_order_items_dataset.csv
    olist_order_payments_dataset.csv
    olist_order_reviews_dataset.csv
    olist_orders_dataset.csv
    olist_products_dataset.csv
    olist_sellers_dataset.csv
    product_category_name_translation.csv
)

# Check every input before inserting any rows.
for file in "${files[@]}" "$verify_sql"; do
    if [[ "$file" == "$verify_sql" ]]; then
        path="$file"
    else
        path="${csv_root}/${file}"
    fi
    if [[ ! -r "$path" ]]; then
        printf 'Cannot read input file: %s\n' "$path" >&2
        exit 1
    fi
done

# Request sudo authentication before passing files to psql's standard input.
sudo -v

run_psql() {
    sudo docker compose exec -T database \
        psql -X -v ON_ERROR_STOP=1 -P pager=off \
        -U lab_admin -d home_data_lab "$@"
}

# Abort the initial import if any target table already contains data.
run_psql <<'SQL'
DO $import_check$
DECLARE
    target_table text;
    has_rows boolean;
BEGIN
    FOREACH target_table IN ARRAY ARRAY[
        'customers', 'geolocation', 'order_items', 'order_payments',
        'order_reviews', 'orders', 'products', 'sellers',
        'product_category_name_translation'
    ] LOOP
        EXECUTE format(
            'SELECT EXISTS (SELECT 1 FROM olist.%I)', target_table
        ) INTO has_rows;
        IF has_rows THEN
            RAISE EXCEPTION
                'olist.% already contains rows; import stopped to avoid duplicates',
                target_table;
        END IF;
    END LOOP;
END;
$import_check$;
SQL

# The shell opens each host CSV and Docker forwards it to psql in the container.
# COPY reads that stream through the existing PostgreSQL connection.
for i in "${!tables[@]}"; do
    printf '\nLoading %s -> olist.%s\n' "${files[$i]}" "${tables[$i]}"
    run_psql -c \
        "COPY olist.${tables[$i]} FROM STDIN WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');" \
        < "${csv_root}/${files[$i]}"
done

printf '\nRow counts: actual versus expected from data/sources.json\n'
run_psql < "$verify_sql"
