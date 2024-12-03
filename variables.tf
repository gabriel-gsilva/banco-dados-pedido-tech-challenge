variable "region" {
  description = "A região da AWS onde os recursos serão criados"
  type        = string
  default     = "sa-east-1"
}

variable "vpc_cidr" {
  description = "O bloco CIDR para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_subnets" {
  description = "Lista de CIDRs para as subnets da VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "db_allocated_storage" {
  description = "O tamanho do armazenamento alocado para o banco de dados RDS em gigabytes"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "A classe de instância para o banco de dados RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "O nome do banco de dados"
  type        = string
  default     = "FiapDeliveryOrder"
}

variable "db_username" {
  description = "O nome de usuário para o banco de dados RDS"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "A senha para o banco de dados RDS"
  type        = string
  default     = "adminpassword123"
  sensitive   = true
}