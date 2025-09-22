output "bastion_external_ip" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "zabbix_internal_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}

output "zabbix_external_ip" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "kibana_external_ip" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "alb_external_ip" {
  value = yandex_alb_load_balancer.web-alb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

output "web_1_internal_ip" {
  value = yandex_compute_instance.web-1.network_interface.0.ip_address
}

output "web_2_internal_ip" {
  value = yandex_compute_instance.web-2.network_interface.0.ip_address
}

output "elastic_internal_ip" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}