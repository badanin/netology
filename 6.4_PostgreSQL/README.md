# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

- *Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.*

```bash
mkdir -p docker-compose/postgres
cd docker-compose/postgres

echo -e "version: '3.1'
services:
  db:
    image: postgres:13
    restart: unless-stopped
    environment:
      - POSTGRES_PASSWORD=1
    ports:
      - 5432:5432
    volumes:
      - ./data:/var/lib/postgresql/data
" > docker-compose.yml

docker-compose up -d
docker exec -ti -u postgres postgres_postgres_1 psql
```

- *Подключитесь к БД PostgreSQL используя `psql`.*

```bash
docker exec -ti -u postgres postgres_db_1 psql
```

- *Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам. Найдите и приведите управляющие команды для:*

  - *вывода списка БД* 

```text
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

  - *подключения к БД* 

```text
  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}

postgres=# \c postgres
You are now connected to database "postgres" as user "postgres".
```

  - *вывода списка таблиц* 

```text
  \dt[S+] [PATTERN]      list tables
```

  - *вывода описания содержимого таблиц* 

```text
  \d[S+]  NAME           describe table, view, sequence, or index
```

  - *выхода из psql* 

```text
  \q                     quit psql
```

## Задача 2

- *Используя `psql` создайте БД `test_database`.*

```bash
docker exec -ti -u postgres postgres_db_1 psql -c "CREATE DATABASE test_database;"
```

- *Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data). Восстановите бэкап БД в `test_database`.*

```bash
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/virt-11/06-db-04-postgresql/test_data/test_dump.sql
docker exec -i -u postgres postgres_db_1 psql test_database < test_dump.sql
```

- *Перейдите в управляющую консоль `psql` внутри контейнера.*

```bash
docker exec -ti -u postgres postgres_db_1 psql
```

- *Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.*

```sql
\c test_database
ANALYZE VERBOSE orders;
```

**Вывод команды**
```text
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

- *Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах. Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.*

```sql
SELECT attname FROM pg_stats
  WHERE tablename='orders' AND avg_width = (
  SELECT MAX(avg_width) FROM pg_stats WHERE tablename='orders');
```

**Вывод команды**
```text
 attname 
---------
 title
(1 row)
```

## Задача 3

- *Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).*
*Предложите SQL-транзакцию для проведения данной операции.*

```sql
START TRANSACTION;

ALTER TABLE orders RENAME TO orders_old;

CREATE TABLE orders (
    id integer,
    title character varying(80),
    price integer
)
PARTITION BY RANGE (price);

CREATE TABLE orders_1
    PARTITION OF orders
    FOR VALUES FROM (500) TO (MAXVALUE);

CREATE TABLE orders_2
    PARTITION OF orders
    FOR VALUES FROM (0) TO (500);

INSERT INTO orders SELECT * FROM orders_old;

DROP TABLE orders_old;

COMMIT;


SELECT * FROM orders;
SELECT * FROM orders_1;
SELECT * FROM orders_2;
```

**Вывод команды:**
```text
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)
```

- *Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?*

Да

```sql
CREATE TABLE orders (
    id integer,
    title character varying(80),
    price integer
)
PARTITION BY RANGE (price);
```

## Задача 4

- *Используя утилиту `pg_dump` создайте бекап БД `test_database`.*

```bash
docker exec -ti -u postgres postgres_db_1 pg_dump test_database > test_database.sql
```

- *Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?*

```bash
sed -i 's/title character varying(80)/title character varying(80) UNIQUE/g' test_database.sql
```

