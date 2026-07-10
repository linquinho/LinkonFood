variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Tamanho da instância EC2 para os microsserviços"
}

variable "db_username" {
  type        = string
  default     = "root"
  description = "Usuário master do banco de dados RDS"
}

variable "db_password" {
  type        = string
  default     = "super_senha"
  sensitive   = true
  description = "Senha do banco de dados RDS"
}