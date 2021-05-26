output "vpc_id" {
  description = "Id of the vpc"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "Ids of the subnets"
  value = {
    for k, v in aws_subnet.subnets : k => v.id
  }
}

output "security_group_id" {
  description = "The id of the security group."
  value       = aws_security_group.my_image_app_security_group.id
}

output "vpc_endpoint_id" {
  description = "The id of the vpc endpoint (to be assigned to an S3 bucket policy)."
  value       = aws_vpc_endpoint.s3_endpoint.id
}