locals {
  zones = [
    "ru-central1-b",
    "ru-central1-a",
    "ru-central1-d",
    # "ru-central1-c" # Is being deprecated, cannot create a cluster here (https://yandex.cloud/en/docs/overview/concepts/ru-central1-c-deprecation)
  ]
  hosts_no      = var.is_HA ? var.HA_hosts : 1
  cidr_division = var.is_HA ? min(ceil(local.hosts_no / 2), 2) : 0

  # given_subnets = data.yandex_vpc_subnet.given_subnets
}
