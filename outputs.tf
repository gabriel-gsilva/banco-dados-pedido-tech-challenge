# outputs.tf

output "vpc_id" {
  description = "O ID da VPC criada"
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "Os IDs das subnets criadas"
  value       = [for subnet in aws_subnet.main_subnet : subnet.id]
}

output "db_instance_endpoint" {
  description = "O endpoint de conexão para a instância do banco de dados"
  value       = aws_db_instance.mydb.endpoint
}

output "db_instance_name" {
  description = "O nome da instância do banco de dados"
  value       = aws_db_instance.mydb.db_name
}

output "db_instance_username" {
  description = "O nome de usuário para conexão ao banco de dados"
  value       = aws_db_instance.mydb.username
}

output "db_instance_port" {
  description = "A porta na qual o banco de dados aceita conexões"
  value       = aws_db_instance.mydb.port
}

output "db_instance_arn" {
  description = "O ARN da instância do banco de dados"
  value       = aws_db_instance.mydb.arn
}