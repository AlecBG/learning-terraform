output "vpc_id" {
  description = "Id of the vpc"
  value       = aws_vpc.main.id
}

output "subnet1_id" {
  description = "Id of the first subnet"
  value       = aws_subnet.subnet_a.id
}

output "subnet2_id" {
  description = "Id of the second subnet"
  value       = aws_subnet.subnet_b.id
}

output "subnet3_id" {
  description = "Id of the third subnet"
  value       = aws_subnet.subnet_c.id
}

output "security_group_id" {
  description = "The id of the security group."
  value       = aws_security_group.my_image_app_security_group.id
}

output "vpc_endpoint_id" {
  description = "The id of the vpc endpoint (to be assigned to an S3 bucket policy)."
  value       = aws_vpc_endpoint.s3_endpoint.id
}