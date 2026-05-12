variable "app_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_cluster_id" { type = string }
variable "alb_sg_id" { type = string }
variable "backend_alb_dns" { type = string }
variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}
variable "log_retention_days" { type = number; default = 14 }
