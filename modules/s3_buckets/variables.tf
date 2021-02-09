variable "bucket_name" {
  description = "Name of S3 bucket storing images"
  type        = string
}

variable "replica_bucket_name" {
  description = "Name of S3 replica bucket storing images as back-up"
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

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-image-app"
}

variable "vpc_endpoint_id" {
  description = "VPC endpoint for S3 bucket communication."
  type        = string
}

variable "tags" {
  description = "Tags to set on the bucket"
  type        = map(string)
  default     = {}
}
