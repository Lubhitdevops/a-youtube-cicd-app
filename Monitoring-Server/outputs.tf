output "instance_id" {
  description = "ID of the monitoring EC2 instance"
  value       = aws_instance.monitoring_server.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.monitoring_server.public_ip
}
