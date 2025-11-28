// outputs.tf
// Output values from the ecs_fargate module so other parts of the stack
// and runbooks can reference the cluster, service, and logs.

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "service_arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.app.arn
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Logs log group for the application."
  value       = aws_cloudwatch_log_group.app.name
}


