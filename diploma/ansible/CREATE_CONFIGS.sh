#cd diploma/ansible/
source env.sh

echo -e "\n=== Exported Variables ==="
echo "BASTION_EXT_IP: $BASTION_EXT_IP"
echo "ZABBIX_EXT_IP: $ZABBIX_EXT_IP"
echo "KIBANA_EXT_IP: $KIBANA_EXT_IP"

echo "ZABBIX_INT_IP: $ZABBIX_INT_IP"
echo "KIBANA_INT_IP: $KIBANA_INT_IP"
echo "WEB_1_INT_IP: $WEB_1_INT_IP"
echo "WEB_2_INT_IP: $WEB_2_INT_IP"
echo "ELASTIC_INT_IP: $ELASTIC_INT_IP"
echo "ALB_EXT_IP: $ALB_EXT_IP"






# Создание vars.yml
cat > ../ansible/vars.yml << EOF
---
BASTION_EXT_IP: $BASTION_EXT_IP
ZABBIX_EXT_IP: $ZABBIX_EXT_IP
KIBANA_EXT_IP: $KIBANA_EXT_IP
ALB_EXT_IP: $ALB_EXT_IP

ZABBIX_INT_IP: $ZABBIX_INT_IP
KIBANA_INT_IP: $KIBANA_INT_IP
WEB_1_INT_IP: $WEB_1_INT_IP
WEB_2_INT_IP: $WEB_2_INT_IP
ELASTIC_INT_IP: $ELASTIC_INT_IP
EOF
echo "==============================================================================="
echo "vars.yml создан"

ANSIBLE_USER=user


# Создание inventory.yml с подставленными значениями
cat > ../ansible/inventory.yml << EOF
all:
  vars:
    ansible_user: $ANSIBLE_USER 
    ansible_ssh_common_args: >
      -o StrictHostKeyChecking=no
      -o UserKnownHostsFile=/dev/null
      -o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null user@$BASTION_EXT_IP"
    
    zabbix_server_ip: $ZABBIX_INT_IP
        # Добавляем хосты для мониторинга
    zabbix_hosts: 
      - name: web-1.ru-central1.internal
        ip: $WEB_1_INT_IP
      - name: web-2.ru-central1.internal
        ip: $WEB_2_INT_IP
      - name: elastic.ru-central1.internal
        ip: $ELASTIC_INT_IP
      - name: kibana.ru-central1.internal
        ip: $KIBANA_INT_IP 
    elastic_server_ip: $ELASTIC_INT_IP

  children:
    bastion:
      hosts:
        bastion.ru-central1.external:
          ansible_host: "$BASTION_EXT_IP"
          ansible_ssh_common_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

    webservers:
      hosts:
        web-1.ru-central1.internal:
          ansible_host: "$WEB_1_INT_IP"
          ansible_ssh_extra_args: "-o StrictHostKeyChecking=no"
        web-2.ru-central1.internal:
          ansible_host: "$WEB_2_INT_IP"
          ansible_ssh_extra_args: "-o StrictHostKeyChecking=no"

    elastic:
      hosts:
        elastic.ru-central1.internal:
          ansible_host: "$ELASTIC_INT_IP"
          ansible_ssh_extra_args: "-o StrictHostKeyChecking=no"



 #   zabbix:
 #     hosts:
 #       zabbix.ru-central1.external:
 #         ansible_host: "$ZABBIX_EXT_IP"
       
    zabbix:
      hosts:
        zabbix.ru-central1.internal:
          ansible_host: "$ZABBIX_INT_IP"
          ansible_ssh_extra_args: "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
          zabbix_admin_user: "Admin"
          zabbix_admin_password: "zabbix"
          zabbix_discovery_name: "Network Discovery"
          zabbix_discovery_iprange: "192.168.0.0/16,192.168.10.0/24,192.168.20.0/24,192.168.30.0/24"
          zabbix_discovery_delay: "10m"
          zabbix_action_name: "Auto Register Linux Hosts"

    kibana:
      hosts:
        kibana.ru-central1.internal:
          ansible_host: "$KIBANA_INT_IP"
          ansible_ssh_extra_args: "-o StrictHostKeyChecking=no"
EOF
echo "==============================================================================="
echo " inventory.yml создан успешно"








# Создание yml с подставленными значениями
echo "==============================================================================="
echo "создаю filebeat.yml"
mkdir -p ./roles/filebeat/files

cat > ./roles/filebeat/files/filebeat.yml << EOF
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/*.log

output.logstash:
  hosts: ["$ELASTIC_INT_IP:5044"]
EOF



# Создание elk.yml с подставленными значениями
echo "==============================================================================="
echo "создаю ./elk.yml"
cat > ./elk.yml << EOF
---
- name: Настройка основного хоста (Elasticsearch, Logstash, Nginx, FileBeat)
  hosts: elastic
  become: yes
  vars:
    elastic_int_ip: $ELASTIC_INT_IP
    kibana_ext_ip: $KIBANA_EXT_IP
    elastic_username: elastic
    elastic_password: SuperSecret123!
    kibana_username: kibana_system
    kibana_password: KibanaPass123!
    docker_registry_username: "{{ lookup('env', 'DOCKER_REGISTRY_USERNAME') | default('your_docker_username', true) }}"
    docker_registry_password: "{{ lookup('env', 'DOCKER_REGISTRY_PASSWORD') | default('your_docker_password', true) }}"
  roles:
    - elasticsearch

    
- name: Настройка хоста Kibana
  hosts: kibana
  become: yes
  vars:
    #ansible_user: user
    elastic_int_ip: $ELASTIC_INT_IP
    elastic_password: SuperSecret123!
    kibana_username: kibana_system
    kibana_password: KibanaPass123!
  roles:
    - kibana
    
EOF


# Создание zabbix-agent.yml с подставленными значениями
echo "==============================================================================="

echo "создаю ./zabbix-agent.yml"
cat > ./zabbix-agent.yml << EOF

---
- name: Configure Zabbix Server
  hosts: all
  become: yes
  vars:
    Server: $ZABBIX_INT_IP
    ServerActive: $ZABBIX_INT_IP
  


  roles:
    - zabbix-agent

EOF
