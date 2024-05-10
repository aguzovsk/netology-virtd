resource "local_file" "hosts_templatefile" {
  content = templatefile("${abspath(path.module)}/hosts.tftpl",
    {
      webservers = yandex_compute_instance.webserver-vm
      databases  = yandex_compute_instance.database-vm
      storage    = yandex_compute_instance.storage-vm[*]
    }
  )

  filename = "${abspath(path.module)}/hosts.ini"
}

resource "random_password" "each" {
  for_each = toset([for vm in yandex_compute_instance.webserver-vm : vm.name])
  length   = 17
}

resource "null_resource" "web_hosts_provision" {
  depends_on = [yandex_compute_instance.database-vm, yandex_compute_instance.webserver-vm, yandex_compute_instance.storage-vm]

  provisioner "local-exec" {
    # without secrets
    # command     = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.ini ${abspath(path.module)}/test.yml"

    #secrets pass
    #> nonsensitive(jsonencode( {for k,v in random_password.each: k=>v.result}))
    /*
      "{\"netology-develop-platform-web-0\":\"u(qzeC#nKjp*wTOY\",\"netology-develop-platform-web-1\":\"=pA12\\u0026C2eCl[Oe$9\"}"
    */
    command = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.ini ${abspath(path.module)}/test.yml --extra-vars '{\"secrets\": ${nonsensitive(jsonencode({ for vm_name, pass in random_password.each : vm_name => pass.result }))} }'"

    # for complex cases instead  --extra-vars "key=value", use --extra-vars "@some_file.json"

    on_failure  = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
  triggers = {
    # always_run        = "${timestamp()}"                         #всегда т.к. дата и время постоянно изменяются
    playbook_src_hash = file("${abspath(path.module)}/test.yml")   # при изменении содержимого playbook файла
    ssh_public_key    = local.ssh_key                              # при изменении переменной with ssh
    template_rendered = "${local_file.hosts_templatefile.content}" #при изменении inventory-template
    password_change   = jsonencode({ for vm_name, pass in random_password.each : vm_name => pass.result })

  }
}
