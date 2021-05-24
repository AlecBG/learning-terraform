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

resource "aws_route53_record" "api_record" {
  zone_id = var.hosted_zone_id
  name    = "api.${var.domain_name}"
  type    = "A"
  alias {
    name                   = var.load_balancer_domain_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
}
