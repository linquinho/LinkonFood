output "ec2_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "IP publico real do Servidor Rocky Linux na AWS"
}

output "rds_endpoint" {
  value       = aws_db_instance.mysql_db.address
  description = "Retorna Host Mysql"
}
