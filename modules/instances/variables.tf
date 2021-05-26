variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "The VPC id."
  type        = string
}

variable "subnets" {
  description = "Ids of the subnets."
  type        = map(string)
}

variable "security_group_id" {
  description = "The security group id for the ec2s."
  type        = string
}

variable "user_data_file_path" {
  description = "Where the user data for the ec2 instances lives"
  type        = string
}

variable "user_data" {
  description = "The user data for the ec2 instances"
  type        = string
}

variable "image_id" {
  description = "The AMI image id."
  type        = string
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket where images are stored."
  type        = string
}

variable "tags" {
  description = "Tags to set on objects"
  type        = map(string)
  default     = {}
}
