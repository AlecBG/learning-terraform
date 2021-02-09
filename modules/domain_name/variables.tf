variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}


variable "domain_name" {
  description = "The domain name the public access."
  type        = string
  sensitive   = true
}

variable "load_balancer_domain_name" {
  description = "The domain name of the load balancer"
  type        = string
}

variable "load_balancer_zone_id" {
  description = "The hosted zone id of the load balancer"
  type        = string
}

variable "hosted_zone_id" {
  description = "The id of the hosted zone."
  type        = string
}
