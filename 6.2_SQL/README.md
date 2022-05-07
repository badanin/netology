# Домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с 
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

```bash
mkdir -p docker-compose/postgres
cd docker-compose/postgres

echo -e "version: '3.1'
services:
  postgres:
    image: postgres:12
    restart: unless-stopped
    environment:
      - POSTGRES_PASSWORD=1
    ports:
      - 5432:5432
    volumes:
      - ./data:/var/lib/postgresql/data
      - ./backups:/backups
" > docker-compose.yml

docker-compose up -d
docker exec -ti -u postgres postgres_postgres_1 psql
```
> psql (12.10 (Debian 12.10-1.pgdg110+1))  
> Type "help" for help.  
> 
> postgres=#  

## Задача 2

В БД из задачи 1: 

- *создайте пользователя test-admin-user и БД test_db*

```sql
CREATE DATABASE test_db;
CREATE USER "test-admin-user";

\connect test_db
```

- *в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)*

```sql
CREATE TABLE orders (
  id SERIAL,
  наименование TEXT,
  цена INT,
  PRIMARY KEY (id)
);

CREATE TABLE clietns (
  id SERIAL,
  фамилия TEXT,
  страна_проживания TEXT,
  заказ INT,
  PRIMARY KEY (id),
  CONSTRAINT fk_orders
    FOREIGN KEY (заказ)
      REFERENCES orders (id)
);

CREATE INDEX страна_проживания_index ON clietns("страна_проживания");
```

- *предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db*

```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";
```

- *создайте пользователя test-simple-user*

```sql
CREATE USER "test-simple-user";
```

- *предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db*

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
```

---

Приведите:
- *итоговый список БД после выполнения пунктов выше*

```
test_db=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges        
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```

- *описание таблиц (describe)*

```
test_db=# \d orders
                               Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default               
--------------+---------+-----------+----------+------------------------------------
 id           | integer |           | not null | nextval('orders_id_seq'::regclass)
 наименование | text    |           |          | 
 цена         | integer |           |          | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clietns" CONSTRAINT "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

test_db=# \d clietns
                                  Table "public.clietns"
      Column       |  Type   | Collation | Nullable |               Default               
-------------------+---------+-----------+----------+-------------------------------------
 id                | integer |           | not null | nextval('clietns_id_seq'::regclass)
 фамилия           | text    |           |          | 
 страна_проживания | text    |           |          | 
 заказ             | integer |           |          | 
Indexes:
    "clietns_pkey" PRIMARY KEY, btree (id)
    "страна_проживания_index" btree ("страна_проживания")
Foreign-key constraints:
    "fk_orders" FOREIGN KEY ("заказ") REFERENCES orders(id)

```

- *SQL-запрос для выдачи списка пользователей с правами над таблицами test_db*

```sql
SELECT * from information_schema.table_privileges WHERE grantee LIKE 'test%';
```

- *список пользователей с правами над таблицами test_db*

```
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clietns    | INSERT         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clietns    | SELECT         | NO           | YES
 postgres | test-admin-user  | test_db       | public       | clietns    | UPDATE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clietns    | DELETE         | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clietns    | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clietns    | REFERENCES     | NO           | NO
 postgres | test-admin-user  | test_db       | public       | clietns    | TRIGGER        | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clietns    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clietns    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clietns    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clietns    | DELETE         | NO           | NO
(22 rows)

```

## Задача 3

*Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:*
*Таблица orders*

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

```sql
INSERT INTO orders (наименование, цена)
  VALUES
  ('Шоколад', 10),
  ('Принтер', 3000),
  ('Книга',   500),
  ('Монитор', 7000),
  ('Гитара',  4000);
```

---

*Таблица clients*

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

```sql
INSERT INTO clietns (фамилия, страна_проживания)
  VALUES
  ('Иванов Иван Иванович', 'USA'),
  ('Петров Петр Петрович', 'Canada'),
  ('Иоганн Себастьян Бах', 'Japan'),
  ('Ронни Джеймс Дио', 'Russia'),
  ('Ritchie Blackmore', 'Russia');
```

---

*Используя SQL синтаксис:*
- *вычислите количество записей для каждой таблицы*
- *приведите в ответе:*
    - *запросы*
    - *результаты их выполнения.*

```sql
SELECT COUNT(id) FROM orders;
```

```
 count 
-------
     5
(1 row)
```

```sql
SELECT COUNT(id) FROM clietns;
```

```
 count 
-------
     5
(1 row)
```

## Задача 4

*Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.*
*Используя foreign keys свяжите записи из таблиц, согласно таблице:*

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

*Приведите SQL-запросы для выполнения данных операций.*

```sql
UPDATE clietns SET "заказ"=3 WHERE id=1;
UPDATE clietns SET "заказ"=4 WHERE id=2;
UPDATE clietns SET "заказ"=5 WHERE id=3;
```

*Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.*
 
```sql
SELECT * FROM clietns WHERE заказ IS NOT NULL;
```

```
 id |       фамилия        | страна_проживания | заказ 
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```

## Задача 5

*Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).*

```sql
EXPLAIN SELECT * FROM clietns WHERE заказ IS NOT NULL;
```

*Приведите получившийся результат и объясните что значат полученные значения.*

```
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on clietns  (cost=0.00..18.10 rows=806 width=72)
   Filter: ("заказ" IS NOT NULL)
(2 rows)
```

- последовательное чтение данных - **Seq Scan**
- затраты на получение первой строки - **0.00**
- затраты на получение всех строк - **18.10**
- количество возвращаемых строк - **806**
- срединий размер строки - **72**

## Задача 6

*Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).*

```bash
docker exec -ti postgres_postgres_1 bash -c "chown postgres:postgres /backups"

docker exec -ti -u postgres postgres_postgres_1 pg_dump -Fc test_db -f /backups/test_db.dump
docker exec -ti -u postgres postgres_postgres_1 pg_dumpall --roles-only -f /backups/roles-only.sql
```
*Остановите контейнер с PostgreSQL (но не удаляйте volumes).*

```bash
docker-compose down
mv data data-old
```

*Поднимите новый пустой контейнер с PostgreSQL.*

```bash
docker-compose up -d
```

*Восстановите БД test_db в новом контейнере.
Приведите список операций, который вы применяли для бэкапа данных и восстановления.*

```bash
docker exec -ti -u postgres postgres_postgres_1 psql -c "CREATE DATABASE test_db"
docker exec -ti -u postgres postgres_postgres_1 psql -f /backups/roles-only.sql test_db
docker exec -ti -u postgres postgres_postgres_1 pg_restore -d test_db /backups/test_db.dump

docker exec -ti -u postgres postgres_postgres_1 psql -d test_db -c "SELECT * FROM clietns"
```

```
 id |       фамилия        | страна_проживания | заказ 
----+----------------------+-------------------+-------
  4 | Ронни Джеймс Дио     | Russia            |      
  5 | Ritchie Blackmore    | Russia            |      
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(5 rows)
```

