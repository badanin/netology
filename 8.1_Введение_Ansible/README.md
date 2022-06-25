# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. *Установите ansible версии 2.10 или выше.*

```bash
sudo apt install -y ansible ansible-lint
ansible --version
```

```text
ansible 2.10.8
  config file = None
  configured module search path = ['/home/a/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]
```

2. *Создайте свой собственный публичный репозиторий на github с произвольным именем.*
3. *Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.*

[badanin/netology-8.1](https://github.com/badanin/netology-8.1)

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

```bash
ansible-playbook -i inventory/test.yml site.yml
```

```text
PLAY [Print os facts] ***********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [localhost]

TASK [Print OS] *****************************************************************************************************
ok: [localhost] => {
    "msg": "Debian"
}

TASK [Print fact] ***************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP **********************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

**some_fact:**

```
ok: [localhost] => {
    "msg": 12
}
```

2. *Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.*

```bash
grep -rl "12" ./ | xargs sed -i 's/12/all default fact/'
ansible-playbook -i inventory/test.yml site.yml
```

```text
PLAY [Print os facts] ***********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [localhost]

TASK [Print OS] *****************************************************************************************************
ok: [localhost] => {
    "msg": "Debian"
}

TASK [Print fact] ***************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP **********************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

3. *Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.*
4. *Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.*

```bash
docker run -d --name ubuntu ubuntu sleep 20000
docker run -d --name centos7 centos sleep 20000
docker exec ubuntu apt update
docker exec ubuntu apt install -y python3
ansible-playbook -i inventory/prod.yml site.yml
```

```text
PLAY [Print os facts] ***********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP **********************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

**some_fact:**

```text
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}
```

5. *Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.*
6. *Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.*

```bash
grep -rl "deb" ./group_vars/ | xargs sed -i 's/deb/deb default fact/'
grep -rl "el" ./group_vars/ | xargs sed -i 's/el/el default fact/'
ansible-playbook -i inventory/prod.yml site.yml
```

```text
PLAY [Print os facts] ***********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

7. *При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.*

```bash
ansible-vault encrypt group_vars/{deb,el}/examp.yml
cat group_vars/{deb,el}/examp.yml
```

```text
$ANSIBLE_VAULT;1.1;AES256
33333535393537316365353133626230323439366362306165316261316164663365653838303166
3333323034623234353933613661623561316531393438330a326465393066376632326331306164
35636533303838346337363365653238353061346264366166383331313066636162613430323538
3731303064393533300a336563346233303235393635643833646365393030353132343635666631
37336138346332326234343338656339616465623730313264646635386463653461333133396533
3031356232373863646331313166623264663061383239313865
$ANSIBLE_VAULT;1.1;AES256
63333231663263613239316266393961396631666563353237363533383963626137663265616261
3235623662343538353533383231633930323438336263650a333162346165303862343633393436
66343563393130623731346638643738386561663133643435356332376263336435626665373233
6336383336353933620a346164343339336363363636396161306339613032626166653065643838
31356362616138363536633534376534303039623233303463346161306535306536663166666638
6362336563653764343439353536363232393562393865646239
```

8. *Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.*

```bash
ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
```

```text
Vault password: 

PLAY [Print os facts] ***********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *****************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ***************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

9. *Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.*

```bash
ansible-doc -t connection -l
```

```text
ansible.netcommon.httpapi      Use httpapi to run command on network appliances                                 
ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ssh connection                         
ansible.netcommon.napalm       Provides persistent connection using NAPALM                                      
ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol                      
ansible.netcommon.network_cli  Use network_cli to run command on network appliances                             
ansible.netcommon.persistent   Use a persistent unix socket for connection                                      
community.aws.aws_ssm          execute via AWS Systems Manager                                                  
community.docker.docker        Run tasks in docker containers                                                   
community.docker.docker_api    Run tasks in docker containers                                                   
community.general.chroot       Interact with local chroot                                                       
community.general.docker       Run tasks in docker containers                                                   
community.general.funcd        Use funcd to connect to target                                                   
community.general.iocage       Run tasks in iocage jails                                                        
community.general.jail         Run tasks in jails                                                               
community.general.lxc          Run tasks in lxc containers via lxc python library                               
community.general.lxd          Run tasks in lxc containers via lxc CLI                                          
community.general.oc           Execute tasks in pods running on OpenShift                                       
community.general.qubes        Interact with an existing QubesOS AppVM                                          
community.general.saltstack    Allow ansible to piggyback on salt minions                                       
community.general.zone         Run tasks in a zone instance                                                     
community.kubernetes.kubectl   Execute tasks in pods running on Kubernetes                                      
community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt                                          
community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines                                       
community.okd.oc               Execute tasks in pods running on OpenShift                                       
community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools                                       
containers.podman.buildah      Interact with an existing buildah container                                      
containers.podman.podman       Interact with an existing podman container                                       
local                          execute on controller                                                            
paramiko_ssh                   Run tasks via python ssh (paramiko)                                              
psrp                           Run tasks over Microsoft PowerShell Remoting Protocol                            
ssh                            connect via ssh client binary                                                    
winrm                          Run tasks over Microsoft's WinRM
```

10. *В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.*
11. *Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.*

```bash
echo "
  local:
    hosts:
      localhost:
        ansible_connection: local" >> inventory/prod.yml

ansible-playbook --ask-vault-pass -i inventory/prod.yml site.yml
```

```text
Vault password: 

PLAY [Print os facts] ***********************************************************************************************

TASK [Gathering Facts] **********************************************************************************************
ok: [localhost]
ok: [centos7]
ok: [ubuntu]

TASK [Print OS] *****************************************************************************************************
ok: [localhost] => {
    "msg": "Debian"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}

TASK [Print fact] ***************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP **********************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

12. *Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.*

[badanin/netology-8.1](https://github.com/badanin/netology-8.1)

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.
