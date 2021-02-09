variable "bucket_name" {
  description = "Name of S3 bucket storing images"
  type        = string
}

variable "replica_bucket_name" {
  description = "Name of S3 bucket replica storing images"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "aws_back_up_region" {
  description = "AWS region where back ups are stored"
  type        = string
  default     = "eu-west-2"
}

variable "db_username" {
  description = "Username for the RDS database containing the S3 keys."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS database containing the S3 keys."
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "My ip address"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "ami_name" {
  description = "The name of the AMI for the ec2 instances."
  type        = string
}

variable "domain_name" {
  description = "The domain name of the service"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate."
  type        = string
}

variable "hosted_zone_id" {
  description = "The id of the hosted zone."
  type        = string
}

variable "aws_access_key_id" {
  description = "Access key id"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "Secret access key"
  type        = string
  sensitive   = true
}
