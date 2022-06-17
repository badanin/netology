## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. *Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).*
2. *Обратите внимание на период бесплатного использования после регистрации аккаунта.*
3. *Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки базового терраформ конфига.*

**~/.terraformrc:**

```text
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

4. *Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.*

```bash
export TF_VAR_yc_token="TOKEN"
```

**vars.tf:**

```text
variable "yc_token" {
}
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 



```bash
terraform apply 
```

```text
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1 will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "test-terraform"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDECcYLmZ9f7//JE6tZmwHxyy7dijKNx3N4DO9n16I0IZgRFPjW4xbJc+y6EwNJ52wzuu8uFPiWPgx0QT66KRuHa3lwOxM0GxqTXZSXcSSD6hzMQK5sMJEHXcGuWCSxRoRmgspl12BYwWCCAerTM/cF9PrUEqUNY8O6b1mSLYNUaDN5neUHIuS+mrpRWxtCPIS2XgFyaasH8Ijxv5cb6jjwVJUExxI0NXEExXIEWV9CgKeRg+f7J6AsZ5LkVW/sU7WkVMN2BYHT0mj2VGwPnqPLrarnMBVUajSWHFYWdh9fTYhczW5xtpD1BL/CwS2qd7ycI0rDmVn+SLsfUm5oNwtZF5lOAcX9TDDqS5lryXWyTxTgSqyAWLyzwDoYohyUooz+J+LnIxvMXDXUwrCr+AXyoIIF5J7Z7O81j6bDAo3Uys1ZjxdXdIbVXnCT3jQT1gTu4vS644Y+kgmqGUjP6UbTTv2iul9NrWNE3bsVbybbvbq4MVwnH2Aj/HlOvHuzgrs= a@yc
            EOT
        }
      + name                      = "terraform1"
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
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd872tdm7lq9lgbu959k"
              + name        = (known after apply)
              + size        = 4
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
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
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.network-1 will be created
  + resource "yandex_vpc_network" "network-1" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "network1"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_vm_1 = (known after apply)
  + internal_ip_address_vm_1 = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.network-1: Creating...
yandex_vpc_network.network-1: Creation complete after 0s [id=enpla2hirso4i6tkhu57]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 1s [id=e9bad6hvv28eh1tlbj67]
yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Creation complete after 22s [id=fhm3bgob4oh3s80haits]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_vm_1 = "51.250.91.114"
internal_ip_address_vm_1 = "192.168.10.18"
```

---

```bash
terraform destroy
```

```text
...
yandex_compute_instance.vm-1: Destroying... [id=fhm3bgob4oh3s80haits]
yandex_compute_instance.vm-1: Still destroying... [id=fhm3bgob4oh3s80haits, 10s elapsed]
yandex_compute_instance.vm-1: Destruction complete after 14s
yandex_vpc_subnet.subnet-1: Destroying... [id=e9bad6hvv28eh1tlbj67]
yandex_vpc_subnet.subnet-1: Destruction complete after 6s
yandex_vpc_network.network-1: Destroying... [id=enpla2hirso4i6tkhu57]
yandex_vpc_network.network-1: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
```

В качестве результата задания предоставьте:
1. *Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?*

Бразы можно создавать с помощью `Packer`.

2. *Ссылку на репозиторий с исходной конфигурацией терраформа.*

[main.tf](src/main.tf)

