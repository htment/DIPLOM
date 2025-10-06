terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.95.0"
    }
  }
}


resource "yandex_vpc_network" "diploma-network" {
  name = "diploma-network"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diploma-network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private-rt.id
}

resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diploma-network.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.private-rt.id
}


resource "yandex_vpc_gateway" "nat-gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private-rt" {
  name       = "private-rt"
  network_id = yandex_vpc_network.diploma-network.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat-gateway.id
  }
}

resource "yandex_iam_service_account" "vm-sa" {
  name = "vm-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "snapshotter" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.vm-sa.id}"
}

resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion-sg"
  network_id  = yandex_vpc_network.diploma-network.id

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  
  }


  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web-sg" {
  name        = "web-sg"
  network_id  = yandex_vpc_network.diploma-network.id

  ingress {
    description       = "HTTP from ALB"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb-sg.id
  }

  ingress {
    description       = "Zabbix Agent"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.zabbix-sg.id
  }

  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }

 
  ingress {
    description    = "Health Checks from Yandex ALB"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"] 
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb-sg" {
  name        = "alb-sg"
  network_id  = yandex_vpc_network.diploma-network.id

  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Health Checks from Yandex ALB"
    protocol       = "TCP"
    from_port      = 30000
    to_port        = 65535
    v4_cidr_blocks = ["198.18.235.0/24", "198.18.248.0/24"]
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  network_id  = yandex_vpc_network.diploma-network.id

  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Zabbix Server"
    protocol       = "TCP"
    port           = 10051
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elastic-sg" {
  name        = "elastic-sg"
  network_id  = yandex_vpc_network.diploma-network.id

  ingress {
    description       = "Elasticsearch from Kibana and Filebeat"
    protocol          = "TCP"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana-sg.id
  }

  ingress {
    description    = "Elasticsearch cluster"
    protocol       = "TCP"
    port           = 9300
    predefined_target = "self_security_group"
  }

  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
# Новое правило: входящий ICMP от Kibana
  ingress {
    description    = "ICMP from Kibana"
    protocol       = "ICMP"
    from_port      = 0
    to_port        = 0
    v4_cidr_blocks = ["192.168.10.0/24"] # public-subnet
  }

  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  network_id  = yandex_vpc_network.diploma-network.id

  ingress {
    description    = "Kibana Web"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }

# Новое правило: исходящий трафик к Elasticsearch (порт 9200)
  egress {
    description    = "To Elasticsearch"
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = ["192.168.20.0/24"] # private-subnet
  }

  # Новое правило: исходящий ICMP к Elastic
  egress {
    description    = "ICMP to Elastic"
    protocol       = "ICMP"
    from_port      = 0
    to_port        = 0
    v4_cidr_blocks = ["192.168.20.0/24"] # private-subnet
  }

  # Сохраняем общее правило для остального исходящего трафика (если нужно)
  egress {
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
  }

  metadata = {
    "user-data"          = file("${path.module}/cloud-init.yml")
    "serial-port-enable" = "1"
  }



  scheduling_policy {
    preemptible = true
  }
  
}

resource "yandex_compute_instance" "web-1" {
  name        = "web-1"
  hostname    = "web-1"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    "serial-port-enable" = "1"
    "user-data"          = file("${path.module}/cloud-init.yml")
  }

  service_account_id = yandex_iam_service_account.vm-sa.id
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "web-2" {
  name        = "web-2"
  hostname    = "web-2"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    "serial-port-enable" = "1"
    "user-data"          = file("${path.module}/cloud-init.yml")
  }

  service_account_id = yandex_iam_service_account.vm-sa.id
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "zabbix" {
  name        = "zabbix"
  hostname    = "zabbix"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id]
  }

  metadata = {
    "serial-port-enable" = "1"
    "user-data"          = file("${path.module}/cloud-init.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.elastic-sg.id]
  }

  metadata = {
    "serial-port-enable" = "1"
    "user-data"          = file("${path.module}/cloud-init.yml")
  }

  service_account_id = yandex_iam_service_account.vm-sa.id
  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id]
  }

  metadata = {
    "serial-port-enable" = "1"
    "user-data"          = file("${path.module}/cloud-init.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_alb_target_group" "web-tg" {
  name = "web-tg"
  target {
    subnet_id  = yandex_vpc_subnet.private-subnet.id
    ip_address = yandex_compute_instance.web-1.network_interface.0.ip_address
  }
  target {
    subnet_id  = yandex_vpc_subnet.private-subnet-b.id
    ip_address = yandex_compute_instance.web-2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "web-bg" {
  name = "web-bg"
  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web-tg.id]
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web-router" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web-vh" {
  name           = "web-vh"
  http_router_id = yandex_alb_http_router.web-router.id
  route {
    name = "route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-bg.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web-alb" {
  name               = "web-alb"
  network_id         = yandex_vpc_network.diploma-network.id
  security_group_ids = [yandex_vpc_security_group.alb-sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-subnet.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
      }
    }
  }
}

resource "yandex_compute_snapshot_schedule" "daily-snapshots" {
  name = "daily-snapshots"

  schedule_policy {
    expression = "0 2 * * *"
  }

  snapshot_count = 7

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web-1.boot_disk.0.disk_id,
    yandex_compute_instance.web-2.boot_disk.0.disk_id,
    yandex_compute_instance.zabbix.boot_disk.0.disk_id,
    yandex_compute_instance.elastic.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id
  ]
}