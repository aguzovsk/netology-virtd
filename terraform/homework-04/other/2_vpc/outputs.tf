output "subnet" {
  value = {
    subnet_id = yandex_vpc_subnet.simple-subnet.id
    zone      = yandex_vpc_subnet.simple-subnet.zone
  }
}

output "network_id" {
  value = yandex_vpc_network.simple-network.id
}
