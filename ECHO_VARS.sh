#!/bin/bash
source diploma/ansible/env.sh
echo "=========================================="
echo "BASTION_EXT_IP: $BASTION_EXT_IP"
echo "ZABBIX_EXT_IP: $ZABBIX_EXT_IP"
echo "KIBANA_EXT_IP: $KIBANA_EXT_IP"
echo "ZABBIX_INT_IP: $ZABBIX_INT_IP"
echo "KIBANA_INT_IP: $KIBANA_INT_IP"
echo "WEB_1_INT_IP: $WEB_1_INT_IP"
echo "WEB_2_INT_IP: $WEB_2_INT_IP"
echo "ELASTIC_INT_IP: $ELASTIC_INT_IP"
echo "zabbix http://$ZABBIX_EXT_IP/zabbix/  (Admin/zabbix)"
echo "ELASTIC http://$KIBANA_EXT_IP:5601/  (elastic/SuperSecret123!)"
echo "ALB_EXT_IP http://$ALB_EXT_IP:80/"
