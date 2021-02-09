variable "db_username" {
  description = "Username for the RDS database containing the S3 keys,"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS database containing the S3 keys,"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the database"
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

variable "security_group_id" {
  description = "Security group id."
  type        = string
}

variable "subnet_1" {
  description = "Id of first subnet."
  type        = string
}

variable "subnet_2" {
  description = "Id of second subnet."
  type        = string
}

variable "subnet_3" {
  description = "Id of third subnet."
  type        = string
}

variable "tags" {
  description = "Tags to set on the bucket"
  type        = map(string)
  default     = {}
}
