terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.39"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

provider "aws" {
  alias  = "replica_region"
  region = var.aws_back_up_region
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "main_subnet_group"
  subnet_ids = [for k, v in var.subnets : v]
}

resource "aws_db_instance" "s3_key_database" {
  provider                = aws
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  instance_class          = "db.t2.micro"
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  tags                    = var.tags
  skip_final_snapshot     = true
  backup_retention_period = 30
  vpc_security_group_ids  = [var.security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
}

resource "aws_db_instance" "read_replica_database" {
  provider               = aws
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.t2.micro"
  name                   = var.db_name
  username               = var.db_username
  replicate_source_db    = aws_db_instance.s3_key_database.arn
  tags                   = var.tags
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot    = true
}

