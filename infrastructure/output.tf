
output "webserver_public_ip" {
  value       = aws_instance.webserver.public_ip
  description = "Webserver public ip"
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Bastion public ip"
}
output "worker_private_ip" {
  value       = aws_instance.worker.private_ip
  description = "Worker private ip"
}
output "redis_server_private_ip" {
  value       = aws_instance.redis_server.private_ip
  description = "redis_server private ip"
}