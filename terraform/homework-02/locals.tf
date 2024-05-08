locals {
  # netology-develop-platform-db
  # netology-develop-platform-web
  main_domain = "netology"
  environment = "develop"
  project = "platform"
  vm_web_name = "${local.main_domain}-${local.environment}-${local.project}-web"
  vm_db_name = "${local.main_domain}-${local.environment}-${local.project}-db"
}