module "my-vpc" {
    source = "../vpc"
    env_name = "my-vpc"
    subnets = [{
      zone = var.zone,
      cidr = "10.0.15.0/24"
    }]
}

data "yandex_compute_image" "ubuntu-2204" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "ubuntu-instance" {
  name = "ubuntu-2204-instance"
  zone = var.zone

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 4
  }

  network_interface {
    #subnet_id = yandex_vpc_subnet.netology-subnets.id
    subnet_id = module.my-vpc.subnets_id[0]
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/yandex-vm.pub")}"
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2204.id
      size = 30
    }
  }

  provisioner "remote-exec" {
    inline = [ "sudo apt install -y curl", "curl -fsSL https://get.docker.com/ | sudo bash" ]

    connection {
      type = "ssh"
      user = "ubuntu"
      password = "antek"
      host = self.network_interface[0].nat_ip_address
    }
  }
}
