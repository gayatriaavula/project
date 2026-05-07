variable "app_name" {
  description = "Application name used to prefix resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR range allowed to reach the public ALB"
  type        = string
  default     = "0.0.0.0/0"
}
