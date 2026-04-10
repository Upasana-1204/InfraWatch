output "server_public_ip" {
  description = "Public IP of InfraWatch server"
  value       = aws_instance.infrawatch_server.public_ip
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${aws_instance.infrawatch_server.public_ip}:3000"
}

output "influxdb_url" {
  description = "InfluxDB URL"
  value       = "http://${aws_instance.infrawatch_server.public_ip}:8086"
}
