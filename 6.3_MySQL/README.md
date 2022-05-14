# Домашнее задание к занятию "6.3. MySQL"

## Задача 1

- *Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.*

```bash
mkdir -p docker-compose/mysql
cd docker-compose/mysql

echo -e "version: '3.1'
services:
  db:
    image: mysql:8
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=1
    ports:
      - 3306:3306
    volumes:
      - ./data:/var/lib/mysql
" > docker-compose.yml

docker-compose up -d
docker exec -ti mysql_db_1 mysql -p1
```

**Вывод команды:**
```text
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>exit
Bye
```

- *Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.*

```bash
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql

docker exec -i mysql_db_1 mysql -p1 -e "create database test_db"
docker exec -i mysql_db_1 mysql -p1 test_db < test_dump.sql
```

- *Перейдите в управляющую консоль `mysql` внутри контейнера.*

```bash
docker exec -ti mysql_db_1 mysql -p1
```

- *Используя команду `\h` получите список управляющих команд.*

```bash
mysql> \h
```

**Вывод команды:** 
```text
For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'
```

- *Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.*

```bash
mysql> \s
```

**Вывод команды:** 
```text
--------------
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)

Connection id:          19
Current database:
Current user:           root@localhost
SSL:                    Not in use
Current pager:          stdout
Using outfile:          ''
Using delimiter:        ;
Server version:         8.0.29 MySQL Community Server - GPL
Protocol version:       10
Connection:             Localhost via UNIX socket
Server characterset:    utf8mb4
Db     characterset:    utf8mb4
Client characterset:    latin1
Conn.  characterset:    latin1
UNIX socket:            /var/run/mysqld/mysqld.sock
Binary data as:         Hexadecimal
Uptime:                 24 min 2 sec

Threads: 2  Questions: 94  Slow queries: 0  Opens: 217  Flush tables: 3  Open tables: 133  Queries per second avg: 0.065
--------------
```

- *Подключитесь к восстановленной БД и получите список таблиц из этой БД.*

```bash
mysql> \r test_db
```

**Вывод команды:**
```text
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Connection id:    20
Current database: test_db
```


```sql
SHOW TABLES;
```

**Вывод команды:**
```text
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

- *Приведите в ответе количество записей с `price` > 300.*

```sql
SELECT * FROM orders WHERE price > 300;
```

**Вывод команды:**
```text
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)
```

## Задача 2

*Создайте пользователя test в БД c паролем test-pass, используя:*
- *плагин авторизации mysql_native_password*
- *срок истечения пароля - 180 дней*
- *количество попыток авторизации - 3*
- *максимальное количество запросов в час - 100*
- *аттрибуты пользователя:*
    - *Фамилия "Pretty"*
    - *Имя "James"*

```sql
CREATE USER 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass'
REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 100
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3
ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
```

*Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.*

```sql
GRANT SELECT ON test_db.* TO 'test'@'localhost';
```

*Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.*

```sql
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
```

**Вывод команды:**
```text
+------+-----------+---------------------------------------+
| USER | HOST      | ATTRIBUTE                             |
+------+-----------+---------------------------------------+
| test | localhost | {"fname": "James", "lname": "Pretty"} |
+------+-----------+---------------------------------------+
1 row in set (0.00 sec)
```
## Задача 3

- *Установите профилирование `SET profiling = 1`.*

```sql
SET profiling=1;
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
```
- *Изучите вывод профилирования команд `SHOW PROFILES;`.*

```sql
SHOW PROFILES;
```

**Вывод команды:**
```text
+----------+------------+--------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                              |
+----------+------------+--------------------------------------------------------------------+
|        1 | 0.00071075 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test' |
+----------+------------+--------------------------------------------------------------------+
1 row in set, 1 warning (0.00 sec)
```

- *Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.*

```sql
SELECT ENGINE FROM information_schema.tables WHERE TABLE_NAME='orders';
```

**Вывод команды:**
```
+--------+
| ENGINE |
+--------+
| InnoDB |
+--------+
1 row in set (0.00 sec)
```

- *Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:*
 - *на `MyISAM`*

```sql
ALTER TABLE orders ENGINE=MyISAM;
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
SHOW PROFILES;
```

**Вывод команды:**
```text
+----------+------------+------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                              |
+----------+------------+------------------------------------------------------------------------------------+
|        1 | 0.00071075 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test'                 |
|        2 | 0.00069875 | SELECT ENGINE FROM information_schema.tables WHERE TABLE_NAME='orders'             |
|        3 | 0.01790450 | ALTER TABLE orders ENGINE=MyISAM                                                   |
|        4 | 0.00051000 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test'                 |
+----------+------------+------------------------------------------------------------------------------------+
6 rows in set, 1 warning (0.00 sec)
```

 - *на `InnoDB`*

```sql
ALTER TABLE orders ENGINE=InnoDB;
SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
SHOW PROFILES;
```

**Вывод команды:**
```text
+----------+------------+------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                              |
+----------+------------+------------------------------------------------------------------------------------+
|        1 | 0.00071075 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test'                 |
|        2 | 0.00069875 | SELECT ENGINE FROM information_schema.tables WHERE TABLE_NAME='orders'             |
|        3 | 0.01790450 | ALTER TABLE orders ENGINE=MyISAM                                                   |
|        4 | 0.00051000 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test'                 |
|        5 | 0.02211100 | ALTER TABLE orders ENGINE=InnoDB                                                   |
|        6 | 0.00067525 | SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test'                 |
+----------+------------+------------------------------------------------------------------------------------+
8 rows in set, 1 warning (0.00 sec)
```

## Задача 4 

*Изучите файл `my.cnf` в директории /etc/mysql.*

*Измените его согласно ТЗ (движок InnoDB):*
- *Скорость IO важнее сохранности данных*
- *Нужна компрессия таблиц для экономии места на диске*
- *Размер буффера с незакомиченными транзакциями 1 Мб*
- *Буффер кеширования 30% от ОЗУ*
- *Размер файла логов операций 100 Мб*

*Приведите в ответе измененный файл `my.cnf`.*

**/etc/mysql/my.cnf**

```text
[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

innodb_flush_log_at_trx_commit  = 2
innodb_file_per_table           = 1
innodb_log_buffer_size          = 1M
innodb_buffer_pool_size         = 614M
innodb_log_file_size            = 100M

!includedir /etc/mysql/conf.d/
```


