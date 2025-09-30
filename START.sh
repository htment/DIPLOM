#!/bin/bash

# Переход в директорию с Terraform
cd /home/art/DIPLOM/diploma/terraform || { echo "Не удалось перейти в директорию Terraform"; exit 1; }

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
bash /home/art/DIPLOM/diploma/ansible/external.sh

echo "Запуск скрипта CREATE_CONFIS"
bash /home/art/DIPLOM/diploma/ansible/CREATE_CONFIGS.sh

# Проверка успешности выполнения предыдущих скриптов
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении одного из скриптов."
    #exit 1
fi

# Запуск Ansible playbook
cd /home/art/DIPLOM/diploma/ansible
echo "==============================================================================="
echo "Запуск Ansible playbook BASTION"
ansible-playbook -i inventory.yml bastion.yml  
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi
echo "==============================================================================="
echo "Запуск Ansible playbook ZABBIX-server"
ansible-playbook -i inventory.yml zabbix-server.yml
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi

echo "==============================================================================="
echo "Запуск Ansible playbook ZABBIX-agent"
ansible-playbook -i inventory.yml zabbix-agent.yml

        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi
echo "==============================================================================="
echo "Запуск Ansible playbook WEB-1,2"
ansible-playbook -i inventory.yml webservers.yml 

        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi
echo "==============================================================================="
ansible-playbook -i inventory.yml elk.yml 
        # Проверка успешности выполнения Ansible playbook
        if [ $? -ne 0 ]; then
            echo "Ошибка при выполнении Ansible playbook."
            exit 1
        fi



echo "Все скрипты и playbook выполнены успешно."