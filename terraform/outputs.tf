output "ec2_public_ip" {
  value       = aws_instance.server.public_ip
  description = "IP do Servidor na AWS"
}

output "rds_endpoint" {
  value       = aws_db_instance.mysql.endpoint
  description = "Endereço do Banco de Dados RDS (Substituir no Docker Compose)"
}