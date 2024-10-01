## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |
| <a name="requirement_lxd"></a> [lxd](#requirement\_lxd) | ~> 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_lxd"></a> [lxd](#provider\_lxd) | 2.3.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.clickhouse_hosts](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [lxd_instance.clickhouse](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/instance) | resource |
| [lxd_instance.lighthouse](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/instance) | resource |
| [lxd_instance.vector](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/instance) | resource |
| [lxd_network.lxd_bridge](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/network) | resource |
| [lxd_profile.netology_ansible_02](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/profile) | resource |
| [lxd_profile.tiny](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/profile) | resource |
| [lxd_storage_pool.netology](https://registry.terraform.io/providers/terraform-lxd/lxd/latest/docs/resources/storage_pool) | resource |
| [terraform_data.clear_clickhouse_ssh](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.clear_lighthouse_ssh](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.clear_vector_ssh](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bridge_CIDR"></a> [bridge\_CIDR](#input\_bridge\_CIDR) | Provide network bridge CIDR range | `string` | `"192.168.61.1/24"` | no |
| <a name="input_clickhouse_server_offset"></a> [clickhouse\_server\_offset](#input\_clickhouse\_server\_offset) | IP addresses of the clickhouse servers will start on the network bridge with given offset | `number` | `11` | no |
| <a name="input_clickhouse_user_name"></a> [clickhouse\_user\_name](#input\_clickhouse\_user\_name) | SSH user name on clickhouse server to which ansible will connect | `string` | `"some"` | no |
| <a name="input_lighthouse_host_offset"></a> [lighthouse\_host\_offset](#input\_lighthouse\_host\_offset) | IP addresses of lighthouse hosts will start on the network bridge with given offset | `number` | `41` | no |
| <a name="input_lighthouse_user_name"></a> [lighthouse\_user\_name](#input\_lighthouse\_user\_name) | SSH user name on lighthouse machine to which ansible will connect | `string` | `"lighthouse"` | no |
| <a name="input_lxd_bridge_name"></a> [lxd\_bridge\_name](#input\_lxd\_bridge\_name) | Name of the linux network bridge that LXD will utilize | `string` | `"my-lxd-bridge-1"` | no |
| <a name="input_network-data_subpath"></a> [network-data\_subpath](#input\_network-data\_subpath) | Relative path where cloud-init network data template file could be found | `string` | `"cloud-init/network-data.yaml.tftpl"` | no |
| <a name="input_playbook_path"></a> [playbook\_path](#input\_playbook\_path) | Relative path to Ansible playbook, where templates should be rendered | `string` | `"../playbook"` | no |
| <a name="input_ssh_key_path"></a> [ssh\_key\_path](#input\_ssh\_key\_path) | Path to public SSH key which will be injected into containers, so you can connect without password | `string` | `"~/.ssh/yandex-vm.pub"` | no |
| <a name="input_user-data_subpath"></a> [user-data\_subpath](#input\_user-data\_subpath) | Relative path where cloud-init user data template file could be found | `string` | `"cloud-init/user-data.yaml.tftpl"` | no |
| <a name="input_vector_host_offset"></a> [vector\_host\_offset](#input\_vector\_host\_offset) | IP addresses of vector hosts will start on the network bridge with given offset | `number` | `21` | no |
| <a name="input_vector_user_name"></a> [vector\_user\_name](#input\_vector\_user\_name) | SSH user name on Datadog vector machine to which ansible will connect | `string` | `"vector"` | no |

## Outputs

No outputs.
