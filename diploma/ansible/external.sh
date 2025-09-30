#!/bin/bash

set -e  # Выход при первой ошибке

cd /home/art/DIPLOM/diploma/terraform || {
    echo "Ошибка: Не удалось перейти в директорию terraform"
    exit 1
}

# Проверяем, инициализирован ли terraform
if [ ! -d ".terraform" ]; then
    echo "Terraform не инициализирован. Запустите: terraform init"
    exit 1
fi

# Выводим все outputs
echo "=== Terraform Outputs ==="
terraform output

# Получаем значения из terraform output
BASTION_EXT_IP=$(terraform output -raw bastion_external_ip)
ZABBIX_EXT_IP=$(terraform output -raw zabbix_external_ip)
KIBANA_EXT_IP=$(terraform output -raw kibana_external_ip)

ZABBIX_INT_IP=$(terraform output -raw zabbix_internal_ip)
KIBANA_INT_IP=$(terraform output -raw kibana_internal_ip)
WEB_1_INT_IP=$(terraform output -raw web_1_internal_ip)
WEB_2_INT_IP=$(terraform output -raw web_2_internal_ip)
ELASTIC_INT_IP=$(terraform output -raw elastic_internal_ip)


export BASTION_EXT_IP
export ZABBIX_EXT_IP
export KIBANA_EXT_IP
export ZABBIX_INT_IP
export KIBANA_INT_IP
export WEB_1_INT_IP
export WEB_2_INT_IP
export ELASTIC_INT_IP



# Проверяем, что переменные не пустые
echo -e "\n=== Exported Variables ==="
echo "BASTION_EXT_IP: $BASTION_EXT_IP"
echo "ZABBIX_EXT_IP: $ZABBIX_EXT_IP"
echo "KIBANA_EXT_IP: $KIBANA_EXT_IP"

echo "ZABBIX_INT_IP: $ZABBIX_INT_IP"
echo "KIBANA_INT_IP: $KIBANA_INT_IP"
echo "WEB_1_INT_IP: $WEB_1_INT_IP"
echo "WEB_2_INT_IP: $WEB_2_INT_IP"
echo "ELASTIC_INT_IP: $ELASTIC_INT_IP"



# Создание env.sh
cat > ../ansible/env.sh << EOF
export BASTION_EXT_IP=$BASTION_EXT_IP
export ZABBIX_EXT_IP=$ZABBIX_EXT_IP
export KIBANA_EXT_IP=$KIBANA_EXT_IP
export ZABBIX_INT_IP=$ZABBIX_INT_IP
export KIBANA_INT_IP=$KIBANA_INT_IP
export WEB_1_INT_IP=$WEB_1_INT_IP
export WEB_2_INT_IP=$WEB_2_INT_IP
export ELASTIC_INT_IP=$ELASTIC_INT_IP
EOF



# Создание vars.yml
cat > ../ansible/vars.yml << EOF
---
BASTION_EXT_IP: $BASTION_EXT_IP
ZABBIX_EXT_IP: $ZABBIX_EXT_IP
KIBANA_EXT_IP: $KIBANA_EXT_IP

ZABBIX_INT_IP: $ZABBIX_INT_IP
KIBANA_INT_IP: $KIBANA_INT_IP
WEB_1_INT_IP: $WEB_1_INT_IP
WEB_2_INT_IP: $WEB_2_INT_IP
ELASTIC_INT_IP: $ELASTIC_INT_IP
EOF






# Создание inventory.yml с подставленными значениями
cat > ../ansible/inventory.yml << EOF
all:
  vars:
    ansible_ssh_common_args: >
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=/dev/null
      -J user@$BASTION_EXT_IP
    
    zabbix_server_ip: $ZABBIX_INT_IP 

  children:
    bastion:
      hosts:
        bastion.ru-central1.external:
          ansible_host: "$BASTION_EXT_IP"
          ansible_ssh_common_args: ""

    webservers:
      hosts:
        web-1.ru-central1.internal:
          ansible_host: "$WEB_1_INT_IP"
        web-2.ru-central1.internal:
          ansible_host: "$WEB_2_INT_IP"

    elastic:
      hosts:
        elastic.ru-central1.internal:
          ansible_host: "$ELASTIC_INT_IP"



 #   zabbix:
 #     hosts:
 #       zabbix.ru-central1.external:
 #         ansible_host: "$ZABBIX_EXT_IP"
       
    zabbix:
      hosts:
        zabbix.ru-central1.internal:
          ansible_host: "$ZABBIX_INT_IP"

    kibana:
      hosts:
        kibana.ru-central1.internal:
          ansible_host: "$KIBANA_INT_IP"
EOF

echo "Файлы vars.yml и inventory.yml созданы успешно"