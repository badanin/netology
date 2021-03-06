# Домашнее задание к занятию "6.6. Troubleshooting"

## Задача 1

*Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).*

*Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её нужно прервать.*

*Вы как инженер поддержки решили произвести данную операцию:*
- *напишите список операций, которые вы будете производить для остановки запроса пользователя*

Поиск длительных операций:

```
db.aggregate( [
    { $currentOp : { allUsers: true, localOps: true } },
    { $match : {op:"query", "secs_running":{$gt:120}} }
] )
```

Завершение операции:

```
db.killOp( OPID )
```

- *предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB*

Можно ограничить максимальное время операции [Terminate Running Operations](https://www.mongodb.com/docs/manual/tutorial/terminate-running-operations/)

```
db.runCommand( { distinct: "collection",
                 key: "city",
                 maxTimeMS: 45 } )
```

## Задача 2

*Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).*

*Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL.*
*Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и увеличивается пропорционально количеству реплик сервиса.*

*При масштабировании сервиса до N реплик вы увидели, что:*
- *сначала рост отношения записанных значений к истекшим*
- *Redis блокирует операции записи*

*Как вы думаете, в чем может быть проблема?*

Возможно из связано с задержками в обращениях БД, которые возникли при масштабировании реплик. Причины возможны разные, к примеру:

- недостаточная производительность одной или нескольких реплик
- задержки дисковой подсистемы
- задержки связанные со средой реализации узлов (виртуализация, котрейнеризация, специфисекое ПО или железо)
- сетевые задержки 

В качетве мер по поиску и устранению проблемы можно предложить:

- чтение логов
- сбор данных по задержкам с помощью `redis-cli --latency`
- точечное отключение реплик и их перераспределение на другие узлы
 
## Задача 3

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:
```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```

*Как вы думаете, почему это начало происходить и как локализовать проблему?*
*Какие пути решения данной проблемы вы можете предложить?*

Вероятно проблема в сетевом взаимодействии или проблема с недостаточной производительностью.
Для решения проблемы можно изменить параметры:

- увеличить значение `net_read_timeout` ([Lost connection to MySQL server](https://dev.mysql.com/doc/refman/8.0/en/error-lost-connection.html))
- увеличить значение `connect_timeout`, `interactive_timeout`, `wait_timeout`

## Задача 4

*Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с большим объемом данных лучше, чем MySQL.*

*После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:*

`postmaster invoked oom-killer`

*Как вы думаете, что происходит?*
*Как бы вы решили данную проблему?*

Данная ошибка возникла из-за недостаточного количества памяти при обработке данных.
Для решения этой проблемы можно задать `vm.overcommit_memory` = 2 ([Deep PostgreSQL Thoughts](https://www.crunchydata.com/blog/deep-postgresql-thoughts-the-linux-assassin)), а так же задать в процентном отношении объем резервируемой памяти `overcommit_ratio`.

