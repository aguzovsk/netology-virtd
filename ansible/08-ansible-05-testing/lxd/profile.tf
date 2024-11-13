resource "lxd_storage_pool" "netology" {
  name   = "netology"
  driver = "btrfs"
  # size   = "20GiB"
}

resource "lxd_network" "lxd_bridge" {
  name = var.lxd_bridge_name

  config = {
    "ipv4.address" = join("", [cidrhost(var.bridge_CIDR, 1), regex("/[0-9]+", var.bridge_CIDR)])
    "ipv4.nat"     = "true"
    "ipv4.dhcp"    = "true" # If dhcp is set off, DNS could not work on OpenSUSE and Debian
    # "raw.dnsmasq"  = file()
  }
}

resource "lxd_profile" "netology_ansible_02" {
  name = "netology_ansible_02"

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = lxd_network.lxd_bridge.name
    }
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      path = "/"
      pool = lxd_storage_pool.netology.name
    }
  }
}

# resource "lxd_profile" "clickhouse" {
#   name = "clickhouse-limits"

#   config = {
#     "limits.cpu"    = 1
#     "limits.memory" = "2GiB"
#   }
# }

# resource "lxd_profile" "tiny" {
#   name = "tiny-limits"

#   config = {
#     "limits.cpu"    = 1
#     "limits.memory" = "512MiB"
#   }
# }

