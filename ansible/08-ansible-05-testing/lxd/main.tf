locals {
  clickhouse_hosts = [
    { name = "debian", image = "images:debian/12/cloud" }
  ]

  # lighthouse_hosts = [
  #   { name = "fedora", image = "images:fedora/40/cloud" },
  #   { name = "centos", image = "images:centos/9-Stream/cloud" },
  #   { name = "debian", image = "images:debian/12/cloud" },
  #   { name = "ubuntu", image = "ubuntu:24.04" },
  #   { name = "opensuse", image = "images:opensuse/tumbleweed/cloud" },
  #   { name = "alpine", image = "images:alpine/edge/cloud" }
  # ]

  # vector_hosts = concat(local.lighthouse_hosts, [])

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

resource "terraform_data" "clickhouse" {
  depends_on = [local_file.inventory]

  count = length(local.clickhouse_hosts)
  triggers_replace = [
    lxd_instance.clickhouse[count.index].ipv4_address
  ]

  input = lxd_instance.clickhouse[count.index].ipv4_address

  provisioner "local-exec" {
    when       = create
    on_failure = fail
    command    = <<-EOT
      ANSIBLE_ROLES_PATH=${path.module}/../../08-ansible-04-role/roles \
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -i ${path.module}/lxd.yaml \
      ${path.module}/../../08-ansible-04-role/playbook/site.yml
    EOT
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.input}"
  }
}
