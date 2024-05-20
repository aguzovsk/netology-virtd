resource "yandex_vpc_network" "netology-devops-network" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "netology-subnets" {
  network_id     = yandex_vpc_network.netology-devops-network.id
  count          = length(var.subnets)
  zone           = var.subnets[count.index].zone
  v4_cidr_blocks = flatten([var.subnets[count.index].cidr])
}

