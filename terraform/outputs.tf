output "ecr_repository_url" {
  description = "ECR repository URL for the backend image"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.backend.name
}

output "backend_url" {
  description = "Public backend endpoint"
  value       = aws_lb.app.dns_name
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_url" {
  description = "Static website URL for the frontend"
  value       = "http://${aws_s3_bucket_website_configuration.frontend.website_endpoint}"
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.default.address
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for backend service"
  value       = aws_cloudwatch_log_group.backend.name
}
