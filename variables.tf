variable "region" {
  type        = string
  description = "A região da AWS onde os recursos serão criados"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block para a VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Lista de CIDRs das sub-redes para a VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  validation {
    condition     = length(var.vpc_subnets) >= 2
    error_message = "Pelo menos duas sub-redes devem ser especificadas para o RDS."
  }
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


variable "db_allocated_storage" {
  type        = number
  description = "Tamanho do armazenamento alocado para o banco de dados em GB"
  default     = 20
}

variable "db_instance_class" {
  type        = string
  description = "Classe da instância do banco de dados"
  default     = "db.t3.micro"
}

variable "db_publicly_accessible" {
  type        = bool
  description = "Especifica se a instância RDS deve ser acessível publicamente"
  default     = false
}