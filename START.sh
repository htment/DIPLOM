#!/bin/bash

START_DIR=$(pwd)

echo "export START_DIR=$START_DIR существует"
export START_DIR=$START_DIR
# Переход в директорию с Terraform
cd ./diploma/terraform || { echo "Не удалось перейти в директорию Terraform"; exit 1; }

# Запуск Terraform apply
echo "Запуск terraform apply..."
terraform apply -auto-approve

# Проверка успешности выполнения Terraform
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении terraform apply."
    exit 1
fi

# Возврат в исходную директорию
cd - || { echo "Не удалось вернуться в исходную директорию"; exit 1; }

# Запуск других скриптов
echo "Соберем адреса ВМ-ок"
bash ./diploma/ansible/external.sh
echo "==============================================================================="
pwd
echo "Запуск скрипта CREATE_CONFIS"
cd diploma/ansible/
bash "$START_DIR/diploma/ansible/CREATE_CONFIGS.sh"
echo "==============================================================================="
# Проверка успешности выполнения предыдущих скриптов
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении одного из скриптов."
    #exit 1
fi

# Запуск Ansible playbook
cd $START_DIR/diploma/ansible
echo "==============================================================================="
echo "Запуск Ansible playbook BASTION"
ansible-playbook -i inventory.yml bastion.yml  
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi
echo "==============================================================================="
echo "Установим ZABBIX-server: ansible-playbook -i inventory.yml zabbix-server.yml "
ansible-playbook -i inventory.yml zabbix-server.yml 
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi

echo "==============================================================================="
echo "Установим ZABBIX-agent: ansible-playbook -i inventory.yml zabbix-agent.yml"
ansible-playbook -i inventory.yml zabbix-agent.yml

        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook zabbix-agent.yml"
            exit 1
        fi
echo "==============================================================================="
echo "Настроим web-сервера:  ansible-playbook -i inventory.yml webservers.yml"
echo "ansible-playbook -i inventory.yml webservers.yml"
ansible-playbook -i inventory.yml webservers.yml 

        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi
echo "==============================================================================="
echo "Установим ELK: ansible-playbook -i inventory.yml elk.yml "
ansible-playbook -i inventory.yml elk.yml 
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi


echo "==============================================================================="
echo "Поставим хосты на мониторинг: ansible-playbook -i inventory.yml zabbix-autodescovery2.yml"
ansible-playbook -i inventory.yml zabbix-autodescovery2.yml
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi


echo "==============================================================================="




cd "$START_DIR"
pwd
echo "Адреса ВМ-ок"
bash ECHO_VARS.sh
echo "Все скрипты и playbook выполнены успешно."
echo "=========================================="
