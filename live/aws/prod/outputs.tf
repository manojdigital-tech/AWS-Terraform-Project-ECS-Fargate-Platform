// outputs.tf
// Key outputs from the prod stack.

output "alb_dns" {
  description = "DNS name of the Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs_fargate.cluster_name
}

output "service_name" {
  description = "ECS service name."
  value       = module.ecs_fargate.service_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for the app."
  value       = module.ecr.repository_url
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret holding DB credentials."
  value       = module.postgres_lite.db_secret_name
}


