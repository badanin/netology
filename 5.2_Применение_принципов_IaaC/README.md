
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

---

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

#### Ответ:

- Автоматизация большинства процессов разработки;
- Воспроизводимость;
- Эффективность разработки.

**Идемпотентность** - воспроизводимость результата независимо от количества подходов.

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

#### Ответ:

**Ansible** имеет модульную структуру и позволяет использовать действующию `ssh` инфраструктуру.
Применение push или pull зависит от условий применения систем управления конфигурацией. При обслуживании большого количества узлов, доступ к которым может быть не постоянным, выгодно использовать pull. Push позволяет обслуживать доступные на данный момент узлы.

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

```bash
$ VBoxManage --version
6.1.30r148432

$ vagrant --version
Vagrant 2.2.19

$ ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/home/a/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]
```
