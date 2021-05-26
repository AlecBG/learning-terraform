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

resource "aws_launch_template" "launch_template" {
  name_prefix   = "my_image_app"
  image_id      = var.image_id
  instance_type = "t2.micro"
  network_interfaces {
    description                 = "My image app network interface. Has public ip address for ssh."
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }
  user_data = var.user_data
  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }
  monitoring {
    enabled = true
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "profile_for_s3_access"
  role = aws_iam_role.trust_policy.name
}

resource "aws_iam_role" "trust_policy" {
  name               = "assume_role"
  assume_role_policy = file("modules/instances/instance_profile_role.json")
}

resource "aws_iam_role_policy" "allow_s3_access" {
  name   = "allow_s3_access"
  role   = aws_iam_role.trust_policy.id
  policy = data.template_file.role_template.rendered
}

data "template_file" "role_template" {
  template = file("modules/instances/role_to_access_s3.json")

  vars = {
    bucket_arn = var.s3_bucket_arn
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  vpc_zone_identifier = [for k, v in var.subnets : v]
  desired_capacity    = 1
  max_size            = 4
  min_size            = 1

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "my-image-app-load-balancer"
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = [for k, v in var.subnets : v]

}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_target_group.arn
  }
}

resource "aws_lb_target_group" "load_balancer_target_group" {
  name                          = "my-image-app-lb-target-group"
  port                          = 5000
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  load_balancing_algorithm_type = "round_robin"
  health_check {
    enabled  = true
    interval = "30" // seconds
    path     = "/health/check"
  }
}

resource "aws_autoscaling_attachment" "my_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
  alb_target_group_arn   = aws_lb_target_group.load_balancer_target_group.arn
}
