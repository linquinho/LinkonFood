variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Tamanho da instancia EC2 para os microsservicos"
}

variable "db_username" {
  type        = string
  default     = "root"
  description = "Usuario master do banco de dados RDS"
}

variable "database_password" {
  type        = string
  sensitive   = true
  description = "Senha do banco de dados RDS MySQL injetada pelo GitHub Secrets"
}

variable "meu_ip_publico" {
  type        = string
  description = "Meu IP publico enviado pelo GitHub"
}

variable "ssh_public_key" {
  type        = string
  description = "Chave publica SSH para permitir que o robô do GitHub faça o deploy"
}
