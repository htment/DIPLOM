# 3. Проверка развернутой инфраструктуры
![alt text](image-9.png)

## Протестируем доступность всех созданных ресурсов:

![alt text](image-7.png)

*(пример вывода после отработки START.sh)*

## 3.1 Подключимся к джампу
``
ssh user@51.250.65.61
``

![alt text](image-3.png)
![alt text](image-4.png)

чтобы получить доступ к остальным хостам нужно подложить приватный ключ с локальной машины 
![alt text](image-5.png)

теперь можем подключаться так:

![alt text](image-6.png)
![alt text](image-8.png)

``ssh -J user@51.250.65.61 user@kibana``

``ssh -J user@51.250.65.61 user@zabbix``

``ssh -J user@51.250.65.61 user@web-1``

``ssh -J user@51.250.65.61 user@web-2``

## 3.2.   Проверка работы сайта

 http://публичный IP балансера:80/
 ![alt text](image.png)
 ![alt text](image-1.png)

 ## 3.2.   Проверка работы ZABBIX
 http://158.160.110.156/zabbix/
 ![alt text](image-10.png)



 ### Проверим, что хосты добавились на мониторинг 

 ![alt text](image-11.png)

  zabbix не мониторит сам себя. Поправим настроки агента на  локалный сервер
```
ssh -J user@51.250.65.61 user@zabbix
sudo nano /etc/zabbix/zabbix_agentd.conf
```
![alt text](image-13.png)
```
sudo systemctl restart zabbix-agent.service
```
видим
![alt text](image-14.png)

### Проверим что правило autodescovery создано:
 ![alt text](image-12.png)

проверим что метрики есть 
![alt text](image-15.png)

## 4. Провериим работу ELASTIC

![alt text](image-16.png)
![alt text](image-17.png)
![alt text](image-18.png)
![alt text](image-19.png)
если из logstash поступают данные то видим это: 
![alt text](image-20.png) 
создаем 

![alt text](image-21.png)

![alt text](image-22.png)
Видим логи nginx

![alt text](image-23.png)
#### Выполним проверки 
![alt text](image-24.png)
- Базовая доступность

```
GET /
```

- Статус кластера
```
GET /_cluster/health
```
- Список узлов
```
GET /_cat/nodes?v
```
- Список индексов
```
GET /_cat/indices?v
```
- Статистика кластера
```
GET /_cluster/stats?human
```

![alt text](image-25.png)