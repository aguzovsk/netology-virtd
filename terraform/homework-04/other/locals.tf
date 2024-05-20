locals {
  bucket_name = "netology-devops-${var.s3-name-suffix}"
  network_id  = data.terraform_remote_state.vpc.outputs.network_id
  subnets     = data.terraform_remote_state.vpc.outputs.subnets
}
