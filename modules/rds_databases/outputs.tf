output "rds_endpoint" {
  description = "Endpoint of the RDB."
  value       = aws_db_instance.s3_key_database.address
}

output "rds_read_replica_endpoint" {
  description = "Endpoint of the RDB read replica."
  value       = aws_db_instance.read_replica_database.address
}

output "rds_port" {
  description = "Port of the rds."
  value       = aws_db_instance.s3_key_database.port
}
