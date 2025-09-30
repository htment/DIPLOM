
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
