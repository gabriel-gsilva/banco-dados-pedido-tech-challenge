provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.db_name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.db_name}"
  }
}

resource "aws_subnet" "main_subnet" {
  count                   = length(var.vpc_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-${var.db_name}-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table-${var.db_name}"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.main_subnet)
  subnet_id      = aws_subnet.main_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "db_sg" {
  name        = "${var.db_name}-sg"
  description = "Security group for ${var.db_name} database"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_name}-sg"
  }
}

resource "aws_db_subnet_group" "default" {
  name_prefix = "${lower(var.db_name)}-subnet-group-"
  subnet_ids  = aws_subnet.main_subnet[*].id

  tags = {
    Name = "${var.db_name} DB subnet group"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "mydb" {
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  identifier              = lower(var.db_name)
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name
  publicly_accessible     = true

  tags = {
    Name        = var.db_name
    Environment = "Development"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.db_name}-lambda-role"

   assume_role_policy= jsonencode({
     Version= "2012-10-17",
     Statement= [{
       Action= "sts:AssumeRole",
       Effect= "Allow",
       Principal= {Service= ["lambda.amazonaws.com"]}
     }]
   })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
 policy_arn= "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
 role= aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "db_setup" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.db_name}-setup"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"

  environment {
    variables = {
      DB_HOST     = aws_db_instance.mydb.endpoint
      DB_USER     = var.db_username
      DB_PASSWORD = var.db_password
      DB_NAME     = var.db_name
    }
  }
}

resource "null_resource" "invoke_lambda" {
  depends_on = [aws_lambda_function.db_setup]

  provisioner "local-exec" {
    command = "aws lambda invoke --function-name ${aws_lambda_function.db_setup.function_name} response.json"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}