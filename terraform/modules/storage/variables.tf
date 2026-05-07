variable "app_name" {
  description = "Application name used to prefix resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
