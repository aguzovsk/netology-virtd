locals {
  clickhouse_hosts_inventory = [
    "${path.module}/${var.playbook_path}/group_vars/vector/clickhouse-hosts.yaml" #,
    # "${path.module}/${var.playbook_path}/group_vars/lighthouse/clickhouse-hosts.yaml"
  ]
}

resource "local_file" "inventory" {
  content = templatefile(
    "${path.module}/template/lxd-inventory.yaml.tftpl",
    {
      groups = {
        clickhouse = {
          user         = var.clickhouse_user_name
          ssh_key_path = var.ssh_key_path
          # tflint-ignore: terraform_deprecated_index
          ips = lxd_instance.clickhouse.*.ipv4_address
        }
        vector = {
          user         = var.vector_user_name
          ssh_key_path = var.ssh_key_path
          # tflint-ignore: terraform_deprecated_index
          ips = lxd_instance.vector.*.ipv4_address
        }
        lighthouse = {
          user         = var.lighthouse_user_name
          ssh_key_path = var.ssh_key_path
          # tflint-ignore: terraform_deprecated_index
          ips = lxd_instance.lighthouse.*.ipv4_address
        }
      }
    }
  )

  filename = "${path.module}/${var.playbook_path}/inventory/lxd.yaml"
}

resource "local_file" "clickhouse_hosts" {
  content = templatefile(
    "${path.module}/template/clickhouse-hosts.yaml.tftpl",
    {
      # tflint-ignore: terraform_deprecated_index
      clickhouse_ips = lxd_instance.clickhouse.*.ipv4_address
    }
  )

  count = length(local.clickhouse_hosts_inventory)

  filename = local.clickhouse_hosts_inventory[count.index]
}

# removed {
#   from = local_file.clickhouse_hosts

#   lifecycle {
#     destroy = false
#   }
# }
