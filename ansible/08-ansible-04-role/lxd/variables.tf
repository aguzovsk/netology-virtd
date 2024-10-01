variable "lxd_bridge_name" {
  type        = string
  default     = "my-lxd-bridge-1"
  description = "Name of the linux network bridge that LXD will utilize"
}

variable "bridge_CIDR" {
  type        = string
  default     = "192.168.61.1/24"
  description = "Provide network bridge CIDR range"

  validation {
    condition     = can(cidrnetmask(var.bridge_CIDR))
    error_message = "Provided CIDR is not valid"
  }
}

variable "clickhouse_server_offset" {
  type        = number
  default     = 11
  description = "IP addresses of the clickhouse servers will start on the network bridge with given offset"
}

variable "vector_host_offset" {
  type        = number
  default     = 21
  description = "IP addresses of vector hosts will start on the network bridge with given offset"
}

variable "lighthouse_host_offset" {
  type        = number
  default     = 41
  description = "IP addresses of lighthouse hosts will start on the network bridge with given offset"
}

variable "ssh_key_path" {
  type        = string
  default     = "~/.ssh/yandex-vm.pub"
  description = "Path to public SSH key which will be injected into containers, so you can connect without password"
}

variable "network-data_subpath" {
  type        = string
  default     = "cloud-init/network-data.yaml.tftpl"
  description = "Relative path where cloud-init network data template file could be found"
}

variable "user-data_subpath" {
  type        = string
  default     = "cloud-init/user-data.yaml.tftpl"
  description = "Relative path where cloud-init user data template file could be found"
}

variable "clickhouse_user_name" {
  type        = string
  default     = "some"
  description = "SSH user name on clickhouse server to which ansible will connect"
}

variable "vector_user_name" {
  type        = string
  default     = "vector"
  description = "SSH user name on Datadog vector machine to which ansible will connect"
}

variable "lighthouse_user_name" {
  type        = string
  default     = "lighthouse"
  description = "SSH user name on lighthouse machine to which ansible will connect"
}

variable "playbook_path" {
  type        = string
  default     = "../playbook"
  description = "Relative path to Ansible playbook, where templates should be rendered"
}
