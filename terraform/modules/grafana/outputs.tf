output "grafana_url" {
  description = "Grafana dashboard URL (admin / your configured password)"
  value       = "http://${aws_lb.monitoring.dns_name}"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://${aws_lb.monitoring.dns_name}/prometheus"
}
