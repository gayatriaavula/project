locals {
  environment = "dev"
}

module "network" {
  source      = "../../modules/network"
  app_name    = var.app_name
  environment = local.environment
  vpc_cidr    = "10.0.0.0/16"
}

module "security" {
  source       = "../../modules/security"
  app_name     = var.app_name
  environment  = local.environment
  vpc_id       = module.network.vpc_id
  allowed_cidr = "0.0.0.0/0"
}

module "storage" {
  source      = "../../modules/storage"
  app_name    = var.app_name
  environment = local.environment
}

module "rds" {
  source                  = "../../modules/rds"
  app_name                = var.app_name
  environment             = local.environment
  db_username             = var.db_username
  db_password             = var.db_password
  db_name                 = var.db_name
  private_subnet_ids      = module.network.private_subnet_ids
  rds_sg_id               = module.security.rds_sg_id
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  backup_retention_period = 0
  deletion_protection     = false
}

module "ecs" {
  source             = "../../modules/ecs"
  app_name           = var.app_name
  environment        = local.environment
  aws_region         = var.aws_region
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  ecs_sg_id          = module.security.ecs_sg_id
  vpc_id             = module.network.vpc_id
  db_host            = module.rds.db_endpoint
  db_username        = var.db_username
  db_password        = var.db_password
  db_name            = var.db_name
  desired_count      = 1
  cpu                = "512"
  memory             = "1024"
  log_retention_days = 7
}

module "monitoring" {
  source                  = "../../modules/monitoring"
  app_name                = var.app_name
  environment             = local.environment
  aws_region              = var.aws_region
  alarm_email             = var.alarm_email
  ecs_cluster_name        = module.ecs.ecs_cluster_name
  ecs_service_name        = module.ecs.ecs_service_name
  alb_arn_suffix          = module.ecs.alb_arn_suffix
  target_group_arn_suffix = module.ecs.target_group_arn_suffix
  rds_identifier          = module.rds.db_identifier
  desired_task_count      = 1
}

module "grafana" {
  source                 = "../../modules/grafana"
  app_name               = var.app_name
  environment            = local.environment
  aws_region             = var.aws_region
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_subnet_ids     = module.network.private_subnet_ids
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  alb_sg_id              = module.security.alb_sg_id
  backend_alb_dns        = module.ecs.backend_url
  grafana_admin_password = var.grafana_admin_password
  log_retention_days     = 7
}
