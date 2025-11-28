// outputs.tf
// Output values from the IAM module so other modules and CI/CD pipelines
// can reference the created roles.

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role."
  value       = aws_iam_role.task_execution_role.arn
}

output "ci_deploy_role_arn" {
  description = "ARN of the CI deploy role."
  value       = aws_iam_role.ci_deploy_role.arn
}

output "developer_readonly_role_arn" {
  description = "ARN of the developer read-only role."
  value       = aws_iam_role.developer_readonly.arn
}


