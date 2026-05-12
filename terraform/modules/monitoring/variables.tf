variable "app_name" {
  description = "Application name used to prefix resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "alarm_email" {
  description = "Email address to receive CloudWatch alarm notifications. Leave empty to disable email alerts."
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ALB target group ARN suffix for CloudWatch metrics"
  type        = string
}

variable "rds_identifier" {
  description = "RDS instance identifier for CloudWatch metrics"
  type        = string
}

variable "desired_task_count" {
  description = "Expected number of running ECS tasks (used for low-task alarm)"
  type        = number
  default     = 1
}
