# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import yaml
import json

dns_list = ['drive.google.com', 'mail.google.com', 'google.com']
dns_ip = {}

while True:

    for dns in dns_list:
        new_ip = socket.gethostbyname(dns)

        if dns not in dns_ip:
            dns_ip[dns] = new_ip
            print(f'{dns} - {dns_ip[dns]}')
            
            with open("./dns_ip.json", 'w') as json_file:
                json_file.write(json.dumps(dns_ip))
            with open("./dns_ip.yaml", 'w') as yaml_file:
                yaml_file.write(yaml.dump(dns_ip, indent = 2, explicit_start = True, explicit_end = True))

        else:
            if dns_ip[dns] != new_ip:
                print(f'{dns} IP mismatch: {dns_ip[dns]} -> {new_ip}')
                dns_ip[dns] = new_ip
            
            with open("./dns_ip.json", 'w') as json_file:
                json_file.write(json.dumps(dns_ip))
            with open("./dns_ip.yaml", 'w') as yaml_file:
                yaml_file.write(yaml.dump(dns_ip, indent = 2, explicit_start = True, explicit_end = True))

```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 74.125.131.194
mail.google.com - 74.125.131.17
google.com - 173.194.73.100
google.com IP mismatch: 173.194.73.100 -> 173.194.73.138
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"drive.google.com": "74.125.131.194", "mail.google.com": "74.125.131.17", "google.com": "173.194.73.138"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
drive.google.com: 74.125.131.194
google.com: 173.194.73.138
mail.google.com: 74.125.131.17
...
```
