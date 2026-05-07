output "ecr_repository_url" {
  description = "ECR repository URL for the backend image"
  value       = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.ecs_service_name
}

output "backend_url" {
  description = "Public backend endpoint"
  value       = module.ecs.backend_url
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = module.storage.frontend_bucket_name
}

output "frontend_url" {
  description = "Static website URL for the frontend"
  value       = module.storage.frontend_url
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for the backend service"
  value       = module.ecs.cloudwatch_log_group
}
