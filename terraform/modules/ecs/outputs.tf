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
  description = "Public backend endpoint (ALB DNS name)"
  value       = aws_lb.app.dns_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for the backend service"
  value       = aws_cloudwatch_log_group.backend.name
}
