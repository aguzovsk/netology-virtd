locals {
  clickhouse_hosts = [
    { name = "debian", image = "images:debian/13/cloud" }
  ]

  lighthouse_hosts = [
    { name = "fedora", image = "images:fedora/40/cloud" },
    { name = "centos", image = "images:centos/9-Stream/cloud" },
    { name = "debian", image = "images:debian/12/cloud" },
    { name = "ubuntu", image = "ubuntu:24.04" },
    { name = "opensuse", image = "images:opensuse/tumbleweed/cloud" },
    { name = "alpine", image = "images:alpine/edge/cloud" }
  ]

  vector_hosts = concat(local.lighthouse_hosts, [])

  gateway_and_dns = cidrhost(var.bridge_CIDR, 1)
}

resource "lxd_instance" "clickhouse" {
  count    = length(local.clickhouse_hosts)
  name     = join("-", [local.clickhouse_hosts[count.index].name, "clickhouse"])
  image    = local.clickhouse_hosts[count.index].image
  type     = "container"
  profiles = [lxd_profile.netology_ansible_02.name]

  limits = {
    cpu    = 1
    memory = "2GiB"
  }

  config = {
    "cloud-init.network-config" = templatefile("${path.module}/${var.network-data_subpath}", {
      ip_address = format("%s/%d",
        cidrhost(var.bridge_CIDR, var.clickhouse_server_offset + count.index),
        regex("[0-9]+$", var.bridge_CIDR)
      )
      os              = local.clickhouse_hosts[count.index].name
      gateway_and_dns = local.gateway_and_dns
    })
    "cloud-init.user-data" = templatefile("${path.module}/${var.user-data_subpath}", {
      user_name = var.clickhouse_user_name,
      ssh_key   = file(var.ssh_key_path),
      os        = local.clickhouse_hosts[count.index].name
    })
  }
}

resource "terraform_data" "clear_clickhouse_ssh" {
  count = length(local.clickhouse_hosts)
  triggers_replace = [
    lxd_instance.clickhouse[count.index].ipv4_address
  ]

  input = lxd_instance.clickhouse[count.index].ipv4_address

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = <<EOT
      ssh-keygen -f ~/.ssh/known_hosts -R ${self.input}
    EOT
  }
}

resource "lxd_instance" "vector" {
  count    = length(local.vector_hosts)
  name     = join("-", [local.vector_hosts[count.index].name, "vector"])
  image    = local.vector_hosts[count.index].image
  type     = "container"
  profiles = [lxd_profile.netology_ansible_02.name, lxd_profile.tiny.name]

  config = {
    "cloud-init.network-config" = templatefile("${path.module}/${var.network-data_subpath}", {
      ip_address = format("%s/%d",
        cidrhost(var.bridge_CIDR, var.vector_host_offset + count.index),
        regex("[0-9]+$", var.bridge_CIDR)
      )
      os              = local.vector_hosts[count.index].name
      gateway_and_dns = local.gateway_and_dns
    })
    "cloud-init.user-data" = templatefile("${path.module}/${var.user-data_subpath}", {
      user_name = var.vector_user_name,
      ssh_key   = file(var.ssh_key_path),
      os        = local.vector_hosts[count.index].name
    })
  }
}

resource "terraform_data" "clear_vector_ssh" {
  count = length(local.vector_hosts)
  triggers_replace = [
    lxd_instance.vector[count.index].ipv4_address
  ]

  input = lxd_instance.vector[count.index].ipv4_address

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = <<EOT
      ssh-keygen -f ~/.ssh/known_hosts -R ${self.input}
    EOT
  }
}

resource "lxd_instance" "lighthouse" {
  count    = length(local.lighthouse_hosts)
  name     = join("-", [local.lighthouse_hosts[count.index].name, "lighthouse"])
  image    = local.lighthouse_hosts[count.index].image
  type     = "container"
  profiles = [lxd_profile.netology_ansible_02.name, lxd_profile.tiny.name]

  config = {
    "cloud-init.network-config" = templatefile("${path.module}/${var.network-data_subpath}", {
      ip_address = format("%s/%d",
        cidrhost(var.bridge_CIDR, var.lighthouse_host_offset + count.index),
        regex("[0-9]+$", var.bridge_CIDR)
      )
      os              = local.lighthouse_hosts[count.index].name
      gateway_and_dns = local.gateway_and_dns
      # cidr_netmask    = cidrnetmask(var.bridge_CIDR)
    })
    "cloud-init.user-data" = templatefile("${path.module}/${var.user-data_subpath}", {
      user_name = var.lighthouse_user_name,
      ssh_key   = file(var.ssh_key_path),
      os        = local.lighthouse_hosts[count.index].name
    })
  }
  # }, local.lighthouse_hosts[count.index].name == "alpine" ? { "security.secureboot" = false } : {})
}


resource "terraform_data" "clear_lighthouse_ssh" {
  count = length(local.lighthouse_hosts)
  triggers_replace = [
    lxd_instance.lighthouse[count.index].ipv4_address
  ]

  input = lxd_instance.lighthouse[count.index].ipv4_address

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = <<EOT
      ssh-keygen -f ~/.ssh/known_hosts -R ${self.input}
    EOT
  }
}
