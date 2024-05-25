resource "yandex_vpc_subnet" "mysql_subnets" {
  count          = var.subnets == null ? min(local.hosts_no, length(local.zones)) : 0
  zone           = local.zones[count.index]
  network_id     = var.network_id
  v4_cidr_blocks = [cidrsubnet(var.cidr_prefix, local.cidr_division, count.index)]
}

# data "yandex_vpc_subnet" "given_subnets" {
#   count     = var.subnets == null ? length(var.subnets) : 0
#   subnet_id = var.subnets[count.index]
# }

locals {
  len = length(yandex_vpc_subnet.mysql_subnets)
}

resource "yandex_mdb_mysql_cluster" "foo" {
  name        = var.cluster_name
  environment = "PRESTABLE"
  network_id  = var.network_id
  version     = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  security_group_ids = [yandex_vpc_security_group.example.id]

  dynamic "host" {
    for_each = toset(range(local.hosts_no))
    content {
      zone      = var.subnets == null ? local.zones[host.key % local.len] : var.subnets[host.key % length(var.subnets)].zone
      subnet_id = var.subnets == null ? yandex_vpc_subnet.mysql_subnets[host.key % local.len].id : var.subnets[host.key % length(var.subnets)].subnet_id
    }
    # content {
    #   zone      = var.subnets == null ? local.zones[host.key % length(local.zones)] : local.given_subnets[host.key % length(local.given_subnets)]
    #   subnet_id = var.subnets == null ? yandex_vpc_subnet.mysql_subnets[host.key % length(local.zones)].id : local.given_subnets[host.key % length(local.given_subnets)]
    # }
  }
}
