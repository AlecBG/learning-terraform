output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.main_bucket.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.main_bucket.id
}
