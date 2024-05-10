output "created-vms-with-loops" {
  value = [for vm in concat(values(yandex_compute_instance.database-vm), yandex_compute_instance.webserver-vm) :
    { "name" = vm.name, "id" = vm.id, "fqdn" = vm.fqdn }
  ]
}
