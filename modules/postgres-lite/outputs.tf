// outputs.tf
// Output values from the postgres-lite module so other modules and
// stacks can reference the database instance and credentials.

output "instance_id" {
  description = "ID of the Postgres EC2 instance."
  value       = aws_instance.postgres.id
}

output "instance_private_ip" {
  description = "Private IP address of the Postgres EC2 instance."
  value       = aws_instance.postgres.private_ip
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret storing DB connection details."
  value       = aws_secretsmanager_secret.db.name
}


