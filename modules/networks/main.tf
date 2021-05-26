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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnets" {
  for_each                = var.azs_to_cidrs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "route_table_for_s3_endpoint" {
  route_table_id  = aws_route_table.route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association_subnets" {
  for_each       = aws_subnet.subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "my_image_app_security_group" {
  name        = "my_image_app_security_group"
  description = "Allow inbound ssh and 443 traffic. Allow all outbound traffic."
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Internal"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh traffic from my laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
