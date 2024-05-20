output "aws_profile" {
  value       = "yandex-${random_id.aws_profile.id}"
  description = "Usage: export AWS_PROFILE=yandex-{random-id} && terraform apply -target module.s3"
}

output "service_account_id" {
  value = yandex_iam_service_account.sa-s3.id
}
