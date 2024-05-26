locals {
  # filter out ru-central1-c zone
  subnets = try(matchkeys(var.subnets, var.subnets[*].zone, ["ru-central1-a", "ru-central1-b", "ru-central1-d"]), null)
  # db_users = [
  #   { name = "app", password = sensitive("password") }
  # ]
}

module "cluster_mysql" {
  source = "./modules/mysql_cluster"
  # cluster_name = "Mysql_sample_cluster"
  cluster_name = "example"
  network_id   = var.network_id

  subnets = local.subnets
  # is_HA   = false
}

module "db_mysql" {
  source     = "./modules/mysql_db"
  cluster_id = module.cluster_mysql.id
  db_name    = "test"
  # db_users   = local.db_users
  db_users = var.db_users
}

