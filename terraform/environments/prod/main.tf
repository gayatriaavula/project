locals {
  environment = "prod"
}

module "network" {
  source      = "../../modules/network"
  app_name    = var.app_name
  environment = local.environment
  vpc_cidr    = "10.2.0.0/16"
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
  instance_class          = "db.t3.medium"
  allocated_storage       = 50
  backup_retention_period = 7
  deletion_protection     = true
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
  desired_count      = 2
  cpu                = "1024"
  memory             = "2048"
  log_retention_days = 30
}
