
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

---

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.


```bash
docker pull nginx:1.21.6-alpine
mkdir nginx
cd nginx/

echo -e "<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>" > index.html

echo -e "FROM nginx:1.21.6-alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80" > Dockerfile

docker build -t nginx-devops5.3 .
```

> Sending build context to Docker daemon  3.072kB  
> Step 1/3 : FROM nginx:1.21.6-alpine  
>  ---> bef258acf10d  
> Step 2/3 : COPY index.html /usr/share/nginx/html/  
>  ---> e677e21be7e3  
> Step 3/3 : EXPOSE 80  
>  ---> Running in fd519cbf5e19  
> Removing intermediate container fd519cbf5e19  
>  ---> 84ac260fb2d2  
> Successfully built 84ac260fb2d2  
> Successfully tagged nginx-devops5.3:latest  

```bash
docker run --name nginx -d -p 8080:80 nginx-devops5.3
curl http://localhost:8080
```

```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

```bash
docker login -u  badaninms
```

> Password:  
> WARNING! Your password will be stored unencrypted in /home/a/.docker/config.json.  
> Configure a credential helper to remove this warning. See  
> https://docs.docker.com/engine/reference/commandline/login/#credentials-store  
>   
> Login Succeeded  

```bash
docker tag nginx-devops5.3:latest badaninms/nginx-devops5.3:latest
docker push badaninms/nginx-devops5.3
```

> Using default tag: latest  
> The push refers to repository [docker.io/badaninms/nginx-devops5.3]  
> 7b5d3b3dc436: Pushed   
> 6fda88393b8b: Mounted from library/nginx   
> a770f8eba3cb: Mounted from library/nginx   
> 318191938fd7: Mounted from library/nginx   
> 89f4d03665ce: Mounted from library/nginx   
> 67bae81de3dc: Mounted from library/nginx   
> 8d3ac3489996: Mounted from library/nginx   
> latest: digest: sha256:7624ca2163088d404336ea6a7889a59048c6c27d90e3c2358404dddc9247e8d3 size: 1775  

#### Ссылка на репозиторий:

<https://hub.docker.com/r/badaninms/nginx-devops5.3>


## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

---

Сценарий:

- Высоконагруженное монолитное java веб-приложение;

Больше подойдет *виртуальная* или *физическая машина*, *docker* как правило используется для микросервисов.

- Nodejs веб-приложение;

*Docker* в данном случае идеально подходит под такого рода задачи.

- Мобильное приложение c версиями для Android и iOS;

*Backend* приложения могут быть запущены в *контейнере*, потому как не связаны с мобильной ОС непосредственно. Для отображения самого приложения будет эффективней использовать *виртуальную машину*.

- Шина данных на базе Apache Kafka;

В рамках архитектуры "распределенной и легко масштабируемой системы обмена сообщениями" должна быть идеальным кандидатом для использования в *контейнерах*.

- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;

Предположительно каждый из данных модулей может быть поднят в отдельном контейнере, что вписывается в парадигму *контейнеров* как микросервисом.

- MongoDB, как основное хранилище данных для java-приложения;

Многие приложения в docker-контейнерах предполагают использование в качестве базы данных именно *контейнерное* решение, в данном случае скорей ни каких ограничений не должно быть.

- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

Gitlab *контейнер* есть в репозитории docker hub и может быть штатно в нем развернут, причин его не использовать не вижу.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```bash
mkdit data
docker run -d -ti --name centos -v $(pwd)/data:/data centos:latest /bin/bash
docker run -d -ti --name debian -v $(pwd)/data:/data debian:latest /bin/bash
docker exec -d centos touch /data/centos.file
docker exec -i debian ls /data
```
> centos.file  
> host.file  

