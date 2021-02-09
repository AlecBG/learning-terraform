output "load_balancer_dns" {
  description = "The DNS of the load balancer"
  value       = aws_lb.load_balancer.dns_name
}

output "load_balancer_zone_id" {
  description = "The hosted zone id of the load balancer"
  value       = aws_lb.load_balancer.zone_id
}
