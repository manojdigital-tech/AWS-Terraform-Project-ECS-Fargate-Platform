// outputs.tf
// Output values from the ECR module so other modules and CI/CD pipelines
// can reference the repository.

output "repository_url" {
  description = "URL of the ECR repository (for example: 123456789012.dkr.ecr.us-east-1.amazonaws.com/repo)."
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "Registry ID that owns the ECR repository."
  value       = aws_ecr_repository.this.registry_id
}


