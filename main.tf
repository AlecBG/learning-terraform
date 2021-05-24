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
  tags = {
    Terraform = "true"
  }
}

module "vpc" {
  source     = "./modules/networks"
  my_ip      = var.my_ip
  aws_region = var.aws_region
  tags = {
    Terraform = "true"
  }
}

module "s3_bucket" {
  source              = "./modules/s3_buckets"
  aws_region          = var.aws_region
  aws_back_up_region  = var.aws_back_up_region
  bucket_name         = var.bucket_name
  replica_bucket_name = var.replica_bucket_name
  vpc_endpoint_id     = module.vpc.vpc_endpoint_id
  tags = {
    Terraform = "true"
  }
}

module "rds_database" {
  source             = "./modules/rds_databases"
  aws_region         = var.aws_region
  aws_back_up_region = var.aws_back_up_region
  db_username        = var.db_username
  db_password        = var.db_password
  db_name            = var.db_name
  security_group_id  = module.vpc.security_group_id
  subnet_1           = module.vpc.subnet1_id
  subnet_2           = module.vpc.subnet2_id
  subnet_3           = module.vpc.subnet3_id
  tags = {
    Terraform = "true"
  }
}

data "template_file" "user_data_template" {
  template = file("user_data.sh")

  vars = {
    bucket_name               = module.s3_bucket.name,
    rds_endpoint              = module.rds_database.rds_endpoint,
//    rds_read_replica_endpoint = module.rds_database.rds_read_replica_endpoint,
    rds_port                  = module.rds_database.rds_port,
    rds_user                  = var.db_username,
    rds_password              = var.db_password,
    rds_db                    = var.db_name,
    aws_access_key_id         = var.aws_access_key_id,
    aws_secret_access_key     = var.aws_secret_access_key,
  }
}

module "instances" {
  source     = "./modules/instances"
  aws_region = var.aws_region
  tags = {
    Terraform = "true"
  }
  vpc_id              = module.vpc.vpc_id
  subnet1_id          = module.vpc.subnet1_id
  subnet2_id          = module.vpc.subnet2_id
  subnet3_id          = module.vpc.subnet3_id
  security_group_id   = module.vpc.security_group_id
  user_data_file_path = "./user_data.sh"
  image_id            = var.ami_name
  ssl_certificate_arn = var.ssl_certificate_arn
  user_data           = base64encode(data.template_file.user_data_template.rendered)
  s3_bucket_arn       = module.s3_bucket.arn
}

module "domain_name" {
  source                    = "./modules/domain_name"
  aws_region                = var.aws_region
  hosted_zone_id            = var.hosted_zone_id
  domain_name               = var.domain_name
  load_balancer_domain_name = module.instances.load_balancer_dns
  load_balancer_zone_id     = module.instances.load_balancer_zone_id
}

