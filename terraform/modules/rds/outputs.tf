output "db_endpoint" {
  description = "RDS database endpoint address"
  value       = aws_db_instance.default.address
}

output "db_identifier" {
  description = "RDS instance identifier for CloudWatch metrics"
  value       = aws_db_instance.default.identifier
}
