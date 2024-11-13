# Issue with stripmarkers and indented heredoc https://github.com/hashicorp/terraform/issues/23710
# If there are any stripmakers in indented heredoc, heredoc cease to be indented
# Cannot to be resolved in 1.x terraform versions

resource "local_file" "inventory" {
  content = <<-EOT
    ---
    clickhouse:
      hosts:
      %{for idx, ipv4 in lxd_instance.clickhouse.*.ipv4_address}
        clickhouse-${format("%02d", idx + 1)}:
          ansible_host: ${ipv4}
          ansible_ssh_user: ${var.clickhouse_user_name}
          ansible_ssh_private_key_file: ${var.ssh_key_path}
      %{endfor}
  EOT

  filename = "${path.module}/lxd.yaml"
}
