/*
  Security group was created in accordance with the guide
  (https://yandex.cloud/en/docs/managed-mysql/operations/connect) + some HTTP(S) traffic
  Assumption: Security groups are stateful
*/
variable "security_group_ingress" {
  description = "Security group to connect over the Internet"
  type = list(object(
    {
      protocol       = string
      description    = string
      v4_cidr_blocks = list(string)
      port           = optional(number)
      from_port      = optional(number)
      to_port        = optional(number)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "allow incoming traffic on port 3306 from any IP address"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 3306
    },
    {
      protocol       = "TCP"
      description    = "allow incoming internal SSH traffic"
      v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      port           = 22
    },
    {
      protocol       = "TCP"
      description    = "allow incoming internal HTTP traffic"
      v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      port           = 80
    },
    {
      protocol       = "TCP"
      description    = "allow incoming internal HTTPs traffic"
      v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      port           = 443
    }
  ]
}


variable "security_group_egress" {
  description = "secrules egress"
  type = list(object(
    {
      protocol       = string
      description    = string
      v4_cidr_blocks = list(string)
      port           = optional(number)
      from_port      = optional(number)
      to_port        = optional(number)
  }))
  default = [
    {
      protocol       = "TCP"
      description    = "allow all outgoing traffic, only internally. Since SGs are stateful, allowed internet requests will be responded"
      v4_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      from_port      = 0
      to_port        = 65365
    }
  ]
}


resource "yandex_vpc_security_group" "example" {
  name       = "example_dynamic"
  network_id = var.network_id

  dynamic "ingress" {
    for_each = var.security_group_ingress
    content {
      protocol       = lookup(ingress.value, "protocol", null)
      description    = lookup(ingress.value, "description", null)
      port           = lookup(ingress.value, "port", null)
      from_port      = lookup(ingress.value, "from_port", null)
      to_port        = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks = lookup(ingress.value, "v4_cidr_blocks", null)
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress
    content {
      protocol       = lookup(egress.value, "protocol", null)
      description    = lookup(egress.value, "description", null)
      port           = lookup(egress.value, "port", null)
      from_port      = lookup(egress.value, "from_port", null)
      to_port        = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = lookup(egress.value, "v4_cidr_blocks", null)
    }
  }
}
