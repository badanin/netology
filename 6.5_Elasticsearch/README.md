# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

*В этом задании вы потренируетесь в:*
- *установке elasticsearch*
- *первоначальном конфигурировании elastcisearch*
- *запуске elasticsearch в docker*

*Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):*

- *составьте Dockerfile-манифест для elasticsearch*

[Dockerfile](Dockerfile)

- *соберите docker-образ и сделайте `push` в ваш docker.io репозиторий*

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-linux-x86_64.tar.gz
docker build . -t badanin87/elastic_netology:v1.0
docker login
docker push badanin87/elastic_netology:v1.0
```

[badanin87/elastic_netology:v1.0](https://hub.docker.com/repository/docker/badanin87/elastic_netology)


- *запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины*

[docker-compose.yml](docker-compose.yml)

*Требования к `elasticsearch.yml`:*
- *данные `path` должны сохраняться в `/var/lib`*
- *имя ноды должно быть `netology_test`*

[elasticsearch.yml](elasticsearch.yml)

```json
{
  "name" : "b7cdb920ffaa",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "7USWX2NdTiKQtb4iF9OOtQ",
  "version" : {
    "number" : "8.2.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "b174af62e8dd9f4ac4d25875e9381ffe2b9282c5",
    "build_date" : "2022-04-20T10:35:10.180408517Z",
    "build_snapshot" : false,
    "lucene_version" : "9.1.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

*В этом задании вы научитесь:*
- *создавать и удалять индексы*
- *изучать состояние кластера*
- *обосновывать причину деградации доступности данных*

*Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:*

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```bash
curl -X PUT http://localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0,  "number_of_shards": 1 }}'
curl -X PUT http://localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 1,  "number_of_shards": 2 }}'
curl -X PUT http://localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 2,  "number_of_shards": 4 }}'
```

*Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.*

```bash
curl -X GET 'http://localhost:9200/_cat/indices?v'
```

```test
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 WlJErS9LRoqmTvKr-cSCXA   1   0          0            0       225b           225b
yellow open   ind-2 Eq2Miu76TGuUMPUdkU315A   2   1          0            0       450b           450b
yellow open   ind-3 z_NzRKznRBGFtr-_9ZMqcw   4   2          0            0       900b           900b
```

```bash
curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
```

```test
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

*Получите состояние кластера `elasticsearch`, используя API.*

```bash
curl -X GET 'http://localhost:9200/_cluster/health/?pretty=true'
```

```text
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

*Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?*

Кластер состоит из одной ноды, реплики не могу быть сделаны на другие ноды.

*Удалите все индексы.*

```bash
curl -X DELETE 'http://localhost:9200/ind-1?pretty'
curl -X DELETE 'http://localhost:9200/ind-2?pretty'
curl -X DELETE 'http://localhost:9200/ind-3?pretty'
```

**Важно**

*При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард, иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.*

## Задача 3

*В данном задании вы научитесь:*
- *создавать бэкапы данных*
- *восстанавливать индексы из бэкапов*

*Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.*

```bash
docker exec -u elasticsearch elasticsearch_elastic_1 mkdir /var/lib/elasticsearch/snapshots
docker exec elasticsearch_elastic_1 bash -c 'echo "path.repo: /var/lib/elasticsearch/snapshots" >> /opt/elasticsearch/config/elasticsearch.yml'
docker restart elasticsearch_elastic_1
```

*Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) данную директорию как `snapshot repository` c именем `netology_backup`.*

*Приведите в ответе запрос API и результат вызова API для создания репозитория.*

```bash
curl -X POST http://localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/var/lib/elasticsearch/snapshots" }}'
```

*Создайте индекс `test` с 0 реплик и 1 шардом и приведите в ответе список индексов.*

```bash
curl -X PUT http://localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0, "number_of_shards": 1 }}'
curl -X GET 'http://localhost:9200/_cat/indices?v'
```

```text
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  Yy5PGFNSR3mFOGwBwzOg7g   1   0          0            0       225b           225b
```

*[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) состояния кластера `elasticsearch`.*

*Приведите в ответе список файлов в директории со `snapshot`ами.*

```bash
curl -X PUT http://localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true
```

```json
{"snapshot":{"snapshot":"elasticsearch","uuid":"WhnlO5hBRAmNt32APhK5kg","repository":"netology_backup","version_id":8020099,"version":"8.2.0","indices":[".geoip_databases","test"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2022-06-12T06:27:42.050Z","start_time_in_millis":1655015262050,"end_time":"2022-06-12T06:27:44.051Z","end_time_in_millis":1655015264051,"duration_in_millis":2001,"failures":[],"shards":{"total":2,"failed":0,"successful":2},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}
```

```bash
ls -la data/snapshots/
```

```text
total 44
drwxr-xr-x 3 a a  4096 июн 12 09:27 .
drwxr-xr-x 5 a a  4096 июн 12 08:49 ..
-rw-r--r-- 1 a a   846 июн 12 09:27 index-0
-rw-r--r-- 1 a a     8 июн 12 09:27 index.latest
drwxr-xr-x 4 a a  4096 июн 12 09:27 indices
-rw-r--r-- 1 a a 18319 июн 12 09:27 meta-WhnlO5hBRAmNt32APhK5kg.dat
-rw-r--r-- 1 a a   359 июн 12 09:27 snap-WhnlO5hBRAmNt32APhK5kg.dat
```

*Удалите индекс `test` и создайте индекс `test-2`. Приведите в ответе список индексов.*

```bash
curl -X DELETE 'http://localhost:9200/test?pretty'
curl -X PUT http://localhost:9200/test-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_replicas": 0, "number_of_shards": 1 }}'
```

```text
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 m0vcQSOfQX25j6ZXJqfVJQ   1   0          0            0       225b           225b
```

*[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние кластера `elasticsearch` из `snapshot`, созданного ранее.*

*Приведите в ответе запрос к API восстановления и итоговый список индексов.*

```bash
curl -X POST 'http://localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?wait_for_completion=true'
curl -X GET 'http://localhost:9200/_cat/indices?v'
```

```text
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test   jtKI80KyQi-1nduevIcS2g   1   0          0            0       225b           225b
green  open   test-2 m0vcQSOfQX25j6ZXJqfVJQ   1   0          0            0       225b           225b
```

*Подсказки:*
- *возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`*
