# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. *(Необязательно) Изучите, что такое [clickhouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [vector](https://www.youtube.com/watch?v=CgEhyffisLY)*
2. *Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.*
3. *Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.*
4. *Подготовьте хосты в соответствии с группами из предподготовленного playbook.*

[badanin/netology-8.2](https://github.com/badanin/netology-8.2)


## Основная часть
1. *Приготовьте свой собственный inventory файл `prod.yml`.*

[prod.yml](nventory/prod.yml)

```yaml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_user: root
      ansible_host: 192.168.1.53
```

2. *Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).*
3. *При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.*
4. *Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, установить vector.*
5. *Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.*

[site.yml](site.yml)

```yaml
---
- name: Install Clickhouse
  hosts: clickhouse
  tasks:
    - block:
        - name: Get clickhouse distrib
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/deb/pool/stable/{{ item }}_{{ clickhouse_version }}_all.deb"
            dest: "/tmp/{{ item }}_{{ clickhouse_version }}.deb"
          with_items: "{{ clickhouse_packages }}"
      rescue:
        - name: Get clickhouse distrib static
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/deb/pool/stable/clickhouse-common-static_{{ clickhouse_version }}_amd64.deb"
            dest: "/tmp/clickhouse-common-static_{{ clickhouse_version }}.deb"
    - name: Install clickhouse clickhouse-common-static
      become: true
      ansible.builtin.apt:
        deb: "/tmp/clickhouse-common-static_{{ clickhouse_version }}.deb"
    - name: Install clickhouse clickhouse-client
      become: true
      ansible.builtin.apt:
        deb: "/tmp/clickhouse-client_{{ clickhouse_version }}.deb"
    - name: Install clickhouse clickhouse-server
      become: true
      ansible.builtin.apt:
        deb: "/tmp/clickhouse-server_{{ clickhouse_version }}.deb"
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: started
    - name: Sleep for 10 seconds and continue with play
      ansible.builtin.wait_for:
        timeout: 10
    - name: Create database
      ansible.builtin.command: "clickhouse-client -q 'CREATE DATABASE IF NOT EXISTS logs;'"
      register: create_db
      failed_when: create_db.rc != 0
      changed_when: create_db.rc == 0
    - name: Create table
      ansible.builtin.command: "clickhouse-client -q 'CREATE TABLE IF NOT EXISTS  logs.journald (message String) ENGINE = MergeTree() ORDER BY tuple();'"
      register: create_table
      failed_when: create_db.rc != 0
      changed_when: create_db.rc == 0

- name: Install Vector
  hosts: clickhouse
  tasks:
    - name: Get vector distrib
      ansible.builtin.get_url:
        url: https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-x86_64-unknown-linux-gnu.tar.gz
        dest: "/tmp/vector_{{ vector_version }}.tar.gz"
    - name: mkdir for vector
      ansible.builtin.file:
        path: /opt/vector
        state: directory
    - name: Extract vector archive
      ansible.builtin.unarchive:
        src: /tmp/vector_{{ vector_version }}.tar.gz
        dest: /opt/vector
        remote_src: yes
        extra_opts: "--strip-components=2"
        group: root
        owner: root
    - name: Create vector bin link
      ansible.builtin.file:
        src: /opt/vector/bin/vector
        dest: /usr/bin/vector
        state: link
    - name: Create vector user
      ansible.builtin.user:
        name: vector
        shell: /bin/bash
    - name: Create vector service link
      ansible.builtin.file:
        src: /opt/vector/etc/systemd/vector.service
        dest: /etc/systemd/system/vector.service
        state: link
    - name: Create vector var folder
      ansible.builtin.file:
        path: /var/lib/vector
        state: directory
        owner: vector
        group: vector
    - name: Create vector config folder
      ansible.builtin.file:
        path: /etc/vector
        state: directory
    - name: Create vector config file
      ansible.builtin.copy:
        src: files/vector.toml
        dest: /etc/vector/vector.toml
    - name: Start vector service
      ansible.builtin.systemd:
        state: started
        name: vector
        daemon_reload: yes
```

6. *Попробуйте запустить playbook на этом окружении с флагом `--check`.*

```bash
ansible-playbook site.yml -i inventory/prod.yml --check
```

```text
PLAY [Install Clickhouse] *************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *********************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "/tmp/clickhouse-common-static_22.6.2.12.deb", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "size": 248679332, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/deb/pool/stable/clickhouse-common-static_22.6.2.12_all.deb"}                                                    

TASK [Get clickhouse distrib static] **************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse clickhouse-common-static] ************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse clickhouse-client] *******************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse clickhouse-server] *******************************************************************
ok: [clickhouse-01]

TASK [Start clickhouse service] *******************************************************************************
ok: [clickhouse-01]

TASK [Sleep for 10 seconds and continue with play] ************************************************************
skipping: [clickhouse-01]

TASK [Create database] ****************************************************************************************
skipping: [clickhouse-01]

TASK [Create table] *******************************************************************************************
skipping: [clickhouse-01]

PLAY [Install Vector] *****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] *************************************************************************************
ok: [clickhouse-01]

TASK [mkdir for vector] ***************************************************************************************
ok: [clickhouse-01]

TASK [Extract vector archive] *********************************************************************************
skipping: [clickhouse-01]

TASK [Create vector bin link] *********************************************************************************
ok: [clickhouse-01]

TASK [Create vector user] *************************************************************************************
ok: [clickhouse-01]

TASK [Create vector service link] *****************************************************************************
ok: [clickhouse-01]

TASK [Create vector var folder] *******************************************************************************
ok: [clickhouse-01]

TASK [Create vector config folder] ****************************************************************************
ok: [clickhouse-01]

TASK [Create vector config file] ******************************************************************************
ok: [clickhouse-01]

TASK [Start vector service] ***********************************************************************************
ok: [clickhouse-01]

PLAY RECAP ****************************************************************************************************
clickhouse-01              : ok=16   changed=0    unreachable=0    failed=0    skipped=4    rescued=1    ignored=0   
```

7. *Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.*
8. *Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.*

```bash
ansible-playbook site.yml -i inventory/prod.yml --diff 
```

```text
PLAY [Install Clickhouse] *************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [clickhouse-01]

TASK [Get clickhouse distrib] *********************************************************************************
ok: [clickhouse-01] => (item=clickhouse-client)
ok: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "/tmp/clickhouse-common-static_22.6.2.12.deb", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "size": 248679332, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/deb/pool/stable/clickhouse-common-static_22.6.2.12_all.deb"}

TASK [Get clickhouse distrib static] **************************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse clickhouse-common-static] ************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse clickhouse-client] *******************************************************************
ok: [clickhouse-01]

TASK [Install clickhouse clickhouse-server] *******************************************************************
ok: [clickhouse-01]

TASK [Start clickhouse service] *******************************************************************************
ok: [clickhouse-01]

TASK [Sleep for 10 seconds and continue with play] ************************************************************
ok: [clickhouse-01]

TASK [Create database] ****************************************************************************************
changed: [clickhouse-01]

TASK [Create table] *******************************************************************************************
changed: [clickhouse-01]

PLAY [Install Vector] *****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [clickhouse-01]

TASK [Get vector distrib] *************************************************************************************
ok: [clickhouse-01]

TASK [mkdir for vector] ***************************************************************************************
ok: [clickhouse-01]

TASK [Extract vector archive] *********************************************************************************
ok: [clickhouse-01]

TASK [Create vector bin link] *********************************************************************************
ok: [clickhouse-01]

TASK [Create vector user] *************************************************************************************
ok: [clickhouse-01]

TASK [Create vector service link] *****************************************************************************
ok: [clickhouse-01]

TASK [Create vector var folder] *******************************************************************************
ok: [clickhouse-01]

TASK [Create vector config folder] ****************************************************************************
ok: [clickhouse-01]

TASK [Create vector config file] ******************************************************************************
ok: [clickhouse-01]

TASK [Start vector service] ***********************************************************************************
ok: [clickhouse-01]

PLAY RECAP ****************************************************************************************************
clickhouse-01              : ok=20   changed=2    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
```

---

```bash
clickhouse-client -q 'SELECT * FROM logs.journald'
```

```text
√ Loaded ["/etc/vector/vector.toml"]
√ Component configuration
√ Health check "out"
------------------------------------
                           Validated
2022-07-03T11:26:38.948075Z  INFO vector::app: Log level is enabled. level="vector=info,codec=info,vrl=info,file_source=info,tower_limit=trace,rdkafka=info,buffers=info,kube=info"
2022-07-03T11:26:38.948558Z  INFO vector::app: Loading configs. paths=["/etc/vector/vector.toml"]
2022-07-03T11:26:38.962367Z  INFO vector::topology::running: Running healthchecks.
2022-07-03T11:26:38.962738Z  INFO vector: Vector has started. debug="false" version="0.22.2" arch="x86_64" build_id="0024c92 2022-06-15"
2022-07-03T11:26:38.962825Z  INFO vector::app: API is disabled, enable by setting `api.enabled` to `true` and use commands like `vector top`.
2022-07-03T11:26:38.966908Z  INFO source{component_kind="source" component_id=in component_type=journald component_name=in}: vector::sources::journald: Starting journalctl.
2022-07-03T11:26:38.968418Z  INFO vector::topology::builder: Healthcheck: Passed.
```

9. *Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.*
10. *Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.*

[badanin/netology-8.2](https://github.com/badanin/netology-8.2)
