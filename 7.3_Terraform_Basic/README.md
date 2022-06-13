# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

*Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со взаимодействием терраформа и aws.*

1. *Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного пользователя, а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы права, как описано [здесь](https://www.terraform.io/docs/backends/types/s3.html).*
2. *Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше.* 

**Не выполнялось**

## Задача 2. Инициализируем проект и создаем воркспейсы. 

**Установка и настройка `yc`**

```bash
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
yc config profile create netology
yc init
```

1. *Выполните `terraform init`:*
    - *если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице dynamodb.*
    - *иначе будет создан локальный файл со стейтами.*  

```bash
terraform init
```

```text
Initializing modules...
Downloading registry.terraform.io/hamnsk/vpc/yandex 0.5.0 for vpc...
- vpc in .terraform/modules/vpc

Initializing the backend...
...
```

2. Создайте два воркспейса `stage` и `prod`.

```bash
terraform workspace new prod
```

```text
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,                                             
so if you run "terraform plan" Terraform will not see any existing state                                          
for this configuration.  
```

```bash
terraform workspace new stage
```

```text
Created and switched to workspace "stage"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

3. *В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных ворскспейсах использовались разные `instance_type`.*
4. *Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два.*
5. *Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, а не `count`.*
6. *Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса добавьте параметр жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.*
7. *При желании поэкспериментируйте с другими параметрами и рессурсами.*  

[main](src/main/main.tf)  
[vars.tf](src/main/vars.tf)  

```bash
terraform plan
```

```text
module.vpc.data.yandex_compute_image.nat_instance: Reading...
module.vpc.data.yandex_compute_image.nat_instance: Read complete after 2s [id=fd8p1fkrsjpao441pjbs]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # module.news.data.yandex_compute_image.image will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "yandex_compute_image" "image" {
      + created_at    = (known after apply)
      + description   = (known after apply)
      + family        = "centos-7"
      + folder_id     = (known after apply)
      + id            = (known after apply)
      + image_id      = (known after apply)
      + labels        = (known after apply)
      + min_disk_size = (known after apply)
      + name          = (known after apply)
      + os_type       = (known after apply)
      + product_ids   = (known after apply)
      + size          = (known after apply)
      + status        = (known after apply)
    }

  # module.news.yandex_compute_instance.instance[0] will be created
  + resource "yandex_compute_instance" "instance" {
      + created_at                = (known after apply)
      + description               = "News App Demo"
      + folder_id                 = "b1gg84ba152kgn1hkjrq"
      + fqdn                      = (known after apply)
      + hostname                  = "news-1"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDECcYLmZ9f7//JE6tZmwHxyy7dijKNx3N4DO9n16I0IZgRFPjW4xbJc+y6EwNJ52wzuu8uFPiWPgx0QT66KRuHa3lwOxM0GxqTXZSXcSSD6hzMQK5sMJEHXcGuWCSxRoRmgspl12BYwWCCAerTM/cF9PrUEqUNY8O6b1mSLYNUaDN5neUHIuS+mrpRWxtCPIS2XgFyaasH8Ijxv5cb6jjwVJUExxI0NXEExXIEWV9CgKeRg+f7J6AsZ5LkVW/sU7WkVMN2BYHT0mj2VGwPnqPLrarnMBVUajSWHFYWdh9fTYhczW5xtpD1BL/CwS2qd7ycI0rDmVn+SLsfUm5oNwtZF5lOAcX9TDDqS5lryXWyTxTgSqyAWLyzwDoYohyUooz+J+LnIxvMXDXUwrCr+AXyoIIF5J7Z7O81j6bDAo3Uys1ZjxdXdIbVXnCT3jQT1gTu4vS644Y+kgmqGUjP6UbTTv2iul9NrWNE3bsVbybbvbq4MVwnH2Aj/HlOvHuzgrs= a@yc
            EOT
        }
      + name                      = "news-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = (known after apply)
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # module.news.yandex_compute_instance.instance[1] will be created
  + resource "yandex_compute_instance" "instance" {
      + created_at                = (known after apply)
      + description               = "News App Demo"
      + folder_id                 = "b1gg84ba152kgn1hkjrq"
      + fqdn                      = (known after apply)
      + hostname                  = "news-2"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDECcYLmZ9f7//JE6tZmwHxyy7dijKNx3N4DO9n16I0IZgRFPjW4xbJc+y6EwNJ52wzuu8uFPiWPgx0QT66KRuHa3lwOxM0GxqTXZSXcSSD6hzMQK5sMJEHXcGuWCSxRoRmgspl12BYwWCCAerTM/cF9PrUEqUNY8O6b1mSLYNUaDN5neUHIuS+mrpRWxtCPIS2XgFyaasH8Ijxv5cb6jjwVJUExxI0NXEExXIEWV9CgKeRg+f7J6AsZ5LkVW/sU7WkVMN2BYHT0mj2VGwPnqPLrarnMBVUajSWHFYWdh9fTYhczW5xtpD1BL/CwS2qd7ycI0rDmVn+SLsfUm5oNwtZF5lOAcX9TDDqS5lryXWyTxTgSqyAWLyzwDoYohyUooz+J+LnIxvMXDXUwrCr+AXyoIIF5J7Z7O81j6bDAo3Uys1ZjxdXdIbVXnCT3jQT1gTu4vS644Y+kgmqGUjP6UbTTv2iul9NrWNE3bsVbybbvbq4MVwnH2Aj/HlOvHuzgrs= a@yc
            EOT
        }
      + name                      = "news-2"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v3"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = (known after apply)
              + name        = (known after apply)
              + size        = 20
              + snapshot_id = (known after apply)
              + type        = "network-ssd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 1
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # module.vpc.yandex_vpc_network.this will be created
  + resource "yandex_vpc_network" "this" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + description               = "managed by terraform prod network"
      + folder_id                 = "b1gg84ba152kgn1hkjrq"
      + id                        = (known after apply)
      + name                      = "prod"
      + subnet_ids                = (known after apply)
    }

  # module.vpc.yandex_vpc_subnet.this["ru-central1-a"] will be created
  + resource "yandex_vpc_subnet" "this" {
      + created_at     = (known after apply)
      + description    = "managed by terraform prod subnet for zone ru-central1-a"
      + folder_id      = "b1gg84ba152kgn1hkjrq"
      + id             = (known after apply)
      + name           = "prod-ru-central1-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.128.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # module.vpc.yandex_vpc_subnet.this["ru-central1-b"] will be created
  + resource "yandex_vpc_subnet" "this" {
      + created_at     = (known after apply)
      + description    = "managed by terraform prod subnet for zone ru-central1-b"
      + folder_id      = "b1gg84ba152kgn1hkjrq"
      + id             = (known after apply)
      + name           = "prod-ru-central1-b"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.129.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

  # module.vpc.yandex_vpc_subnet.this["ru-central1-c"] will be created
  + resource "yandex_vpc_subnet" "this" {
      + created_at     = (known after apply)
      + description    = "managed by terraform prod subnet for zone ru-central1-c"
      + folder_id      = "b1gg84ba152kgn1hkjrq"
      + id             = (known after apply)
      + name           = "prod-ru-central1-c"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.130.0.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-c"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these
actions if you run "terraform apply" now.
```

```bash
terraform apply
```

```text
module.vpc.yandex_vpc_network.this: Creating...
module.vpc.yandex_vpc_network.this: Creation complete after 2s [id=enp8vjhl9rbl24mo0jid]
module.vpc.yandex_vpc_subnet.this["ru-central1-c"]: Creating...
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Creating...
module.vpc.yandex_vpc_subnet.this["ru-central1-b"]: Creating...
module.vpc.yandex_vpc_subnet.this["ru-central1-c"]: Creation complete after 1s [id=b0c0qunggbhu723khop2]
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Creation complete after 1s [id=e9bovd35v7p06of79utk]
module.vpc.yandex_vpc_subnet.this["ru-central1-b"]: Creation complete after 2s [id=e2l3ufstiffgasvl8kpj]
module.news.data.yandex_compute_image.image: Reading...
module.news.data.yandex_compute_image.image: Read complete after 0s [id=fd8ad4ie6nhfeln6bsof]
module.news.yandex_compute_instance.instance[1]: Creating...
module.news.yandex_compute_instance.instance[0]: Creating...
module.news.yandex_compute_instance.instance[0]: Still creating... [10s elapsed]
module.news.yandex_compute_instance.instance[1]: Still creating... [10s elapsed]
module.news.yandex_compute_instance.instance[1]: Still creating... [20s elapsed]
module.news.yandex_compute_instance.instance[0]: Still creating... [20s elapsed]
module.news.yandex_compute_instance.instance[0]: Creation complete after 23s [id=fhm0gbcm55bnprdirjhm]
module.news.yandex_compute_instance.instance[1]: Creation complete after 25s [id=fhmvoq9srj8hp58a52fr]
```

![prod](img/prod.png)

```bash
terraform destroy 
```

```text
module.news.yandex_compute_instance.instance[0]: Destroying... [id=fhm0gbcm55bnprdirjhm]
module.news.yandex_compute_instance.instance[1]: Destroying... [id=fhmvoq9srj8hp58a52fr]
module.news.yandex_compute_instance.instance[0]: Still destroying... [id=fhm0gbcm55bnprdirjhm, 10s elapsed]
module.news.yandex_compute_instance.instance[1]: Still destroying... [id=fhmvoq9srj8hp58a52fr, 10s elapsed]
module.news.yandex_compute_instance.instance[1]: Destruction complete after 13s
module.news.yandex_compute_instance.instance[0]: Destruction complete after 15s
module.vpc.yandex_vpc_subnet.this["ru-central1-b"]: Destroying... [id=e2l3ufstiffgasvl8kpj]
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Destroying... [id=e9bovd35v7p06of79utk]
module.vpc.yandex_vpc_subnet.this["ru-central1-c"]: Destroying... [id=b0c0qunggbhu723khop2]
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Destruction complete after 3s
module.vpc.yandex_vpc_subnet.this["ru-central1-b"]: Destruction complete after 3s
module.vpc.yandex_vpc_subnet.this["ru-central1-c"]: Destruction complete after 6s
module.vpc.yandex_vpc_network.this: Destroying... [id=enp8vjhl9rbl24mo0jid]
module.vpc.yandex_vpc_network.this: Destruction complete after 0s
```
---

```bash
terraform workspace select stage
terraform apply
```

```text
module.vpc.yandex_vpc_network.this: Creating...
module.vpc.yandex_vpc_network.this: Creation complete after 2s [id=enpaabo0mmh2tq7p4mck]
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Creating...
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Creation complete after 1s [id=e9bqmpuov4g6nqh5mfjc]
module.news.data.yandex_compute_image.image: Reading...
module.news.data.yandex_compute_image.image: Read complete after 0s [id=fd8ad4ie6nhfeln6bsof]
module.news.yandex_compute_instance.instance[0]: Creating...
module.news.yandex_compute_instance.instance[0]: Still creating... [10s elapsed]
module.news.yandex_compute_instance.instance[0]: Still creating... [20s elapsed]
module.news.yandex_compute_instance.instance[0]: Creation complete after 22s [id=fhmrgvhulsgg8nuhe1ec]
```
![stage](img/stage.png)

```bash
terraform destroy
```

```text
module.news.yandex_compute_instance.instance[0]: Destroying... [id=fhmrgvhulsgg8nuhe1ec]
module.news.yandex_compute_instance.instance[0]: Still destroying... [id=fhmrgvhulsgg8nuhe1ec, 10s elapsed]
module.news.yandex_compute_instance.instance[0]: Destruction complete after 13s
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Destroying... [id=e9bqmpuov4g6nqh5mfjc]
module.vpc.yandex_vpc_subnet.this["ru-central1-a"]: Destruction complete after 5s
module.vpc.yandex_vpc_network.this: Destroying... [id=enpaabo0mmh2tq7p4mck]
module.vpc.yandex_vpc_network.this: Destruction complete after 1s
```



*В виде результата работы пришлите:*
- *Вывод команды `terraform workspace list`.*
- *Вывод команды `terraform plan` для воркспейса `prod`.*  
