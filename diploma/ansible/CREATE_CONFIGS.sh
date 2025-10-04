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

# Создание inventory.yml с подставленными значениями
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



# Создание inventory.yml с подставленными значениями
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
