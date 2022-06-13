# Домашнее задание к занятию "7.4. Средства командной работы над инфраструктурой."

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

*В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым разработчиками терраформа.*

1. *Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/). (регистрация бесплатная и не требует использования платежных инструментов).*
2. *Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с  конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).*
3. *Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).*
4. *Выполните plan и apply.* 

*В качестве результата задания приложите снимок экрана с успешным применением конфигурации.*

**Не выполнялось**

## Задача 2. Написать серверный конфиг для атлантиса. 

*Смысл задания – познакомиться с документацией о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня  [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).*

*Создай `server.yaml` который скажет атлантису:*
1. *Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.*
1. *На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно будет указать свои дополнительные команды.*
1. *В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.*

*Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:*
1. *Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.*
1. *Необходимо включить автопланирование при изменении любых файлов `*.tf`.*

Устанавливаем `atlantis` и `ngrok` [Atlantis - Testing Locally](https://www.runatlantis.io/guide/testing-locally.html):

```bash
wget -q https://github.com/runatlantis/atlantis/releases/download/v0.19.2/atlantis_linux_amd64.zip
unzip atlantis_linux_amd64.zip
sudo cp atlantis /usr/bin/
```

```bash
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar -xzf ngrok-v3-stable-linux-amd64.tgz
sudo cp ngrok /usr/bin/
```

Запускаем `ngrok`:

```bash
ngrok http 4141
```

![ngrok](img/ngrok.png)

Настраиваем "Webhook Secret":

![webhook](img/webhook.png)

Проверяем `atlantis`:

```bash
atlantis testdrive
```

![testdrive](img/test.png)

Проверка `apply`:

![apply](img/apply.png)


Запускаем `atlantis`:

```bash
atlantis server --atlantis-url=https://e759-5-39-58-152.eu.ngrok.io --gh-user=badanin --gh-token=ghp_d1suPCNb4lfqjJdkL1HZfBs9EF07lz18FQde --gh-webhook-secret=bH6QuSDXfvARFLhwteA3 --repo-allowlist=github.com/badanin/atlantis-example --repo-config=server.yaml
```

![lock](img/lock.png)

*В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.*

[server.yaml](src/server.yaml)  
[atlantis.yaml](src/atlantis.yaml)  


## Задача 3. Знакомство с каталогом модулей. 

1. *В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания`ec2` инстансов.*

[ec2-instance](https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest)

2. *Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно ресурс `aws_instance` без помощи модуля?*

Модули позволяют значительно расширить возможности развертывания большого числа инстансов, при это их конфигурация становится более гибкая. В больших проектах целесообразней использовать модули.

3. *В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. Создайте аналогичный инстанс при помощи найденного модуля.*  

[main.tf](src/main.tf)

*В качестве результата задания приложите ссылку на созданный блок конфигураций.*
