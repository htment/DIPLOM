
# 1. Структура проекта 
1. Блок-схема проекта (Высокоуровневая архитектура)

Эта схема показывает основные компоненты системы и их взаимодействие.
https://github.com/htment/DIPLOM/tree/main/diploma
![alt text](image.png)
# 2. Развррачиваем инфраструктуру
Описание настройки 
https://github.com/htment/DIPLOM/blob/main/diploma/README.md

# 3.  Тестирование сервисов



sudo docker exec -it elasticsearch bash


/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana


(http://89.169.151.70:5601/)




sudo docker exec -it kibana_kibana_1 bash

/usr/share/kibana/bin/kibana-verification-code

Укажите адрес Elasticsearch:

Введите адрес Elasticsearch. Вместо https://172.18.0.2:9200 попробуйте использовать внутренний IP-адрес сервера Elasticsearch:
text
https://192.168.20.12:9200
Это внутренний IP-адрес сервера Elasticsearch, указанный в ваших данных.