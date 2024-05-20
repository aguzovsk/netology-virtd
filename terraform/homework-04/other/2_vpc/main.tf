resource "yandex_vpc_network" "simple-network" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "simple-subnet" {
  network_id     = yandex_vpc_network.simple-network.id
  zone           = var.zone
  v4_cidr_blocks = [var.cidr]
}
