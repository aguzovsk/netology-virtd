locals {
  ssh_key = file("~/.ssh/yandex-vm.pub")

  # ${abspath(path.module)}
  cloud_init_config = templatefile("${path.module}/cloud-init.yml",
    {
      ssh_keys = [local.ssh_key]
    }
  )

  metadata = {
    serial-port-enable = 1
    user-data          = local.cloud_init_config
  }
}
