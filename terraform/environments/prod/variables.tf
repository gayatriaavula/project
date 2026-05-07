variable "aws_region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used to prefix resources"
  type        = string
  default     = "sample-app"
}

variable "db_password" {
  description = "Password for the RDS MySQL database"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "sampledb"
}
