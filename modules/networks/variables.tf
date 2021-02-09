variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "Tags to set on objects"
  type        = map(string)
  default     = {}
}

variable "my_ip" {
  description = "My ip address"
  type        = string
  sensitive   = true
}
