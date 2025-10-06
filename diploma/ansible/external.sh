#!/bin/bash
# Проверяем, задана ли START_DIR, если нет — задаем
if [ -z "$START_DIR" ]; then
    START_DIR=$(dirname "$(dirname "$(pwd)")")
fi

echo "START_DIR=$START_DIR"
START_DIR_inv=$START_DIR

if [ -v "${START_DIR_inv}" ];
then
    echo "START_DIR_inv=$START_DIR_inv существует"
    cd "$START_DIR/diploma/terraform" || {
    echo "Ошибка: Не удалось перейти в директорию terraform"
    exit 1
    }

else
    echo "Переменная START_DIR_inv=$START_DIR_inv не существует"
    START_DIR_inv=$(pwd)
    pwd
    echo "Переход ../terraform"
    cd "$START_DIR/diploma/terraform"
   
fi

echo $START_DIR_inv





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
ALB_EXT_IP=$(terraform output -raw alb_external_ip)

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
export ALB_EXT_IP

sudo tee /etc/profile.d/terraform-vars.sh > /dev/null <<EOF
export BASTION_EXT_IP=$BASTION_EXT_IP
export ZABBIX_EXT_IP=$ZABBIX_EXT_IP
export KIBANA_EXT_IP=$KIBANA_EXT_IP
export ZABBIX_INT_IP=$ZABBIX_INT_IP
export KIBANA_INT_IP=$KIBANA_INT_IP
export WEB_1_INT_IP=$WEB_1_INT_IP
export WEB_2_INT_IP=$WEB_2_INT_IP
export ELASTIC_INT_IP=$ELASTIC_INT_IP
export ALB_EXT_IP=$ALB_EXT_IP
EOF




# Проверяем, что переменные не пустые
echo -e "\n=== Exported Variables ==="
echo "BASTION_EXT_IP: $BASTION_EXT_IP"
echo "ZABBIX_EXT_IP: $ZABBIX_EXT_IP"
echo "KIBANA_EXT_IP: $KIBANA_EXT_IP"
echo "ALB_EXT_IP: $ALB_EXT_IP"

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
export ALB_EXT_IP=$ALB_EXT_IP
EOF

