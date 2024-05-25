output "network_id" {
  value = yandex_vpc_network.netology-devops-network.id
}

output "subnets" {
  value = [for subnet in yandex_vpc_subnet.netology-subnets : { subnet_id = subnet.id, zone = subnet.zone }]
}

