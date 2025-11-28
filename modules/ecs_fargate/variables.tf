// variables.tf
// Input variables for the ecs_fargate module.
// These control how the ECS cluster, task definition, and service are configured.

variable "environment" {
  description = "Environment name (for example: dev, stage, prod). Used for naming and tagging."
  type        = string
}

variable "project" {
  description = "Project tag value used for naming and tagging (for example: infra-project)."
  type        = string
  default     = "infra-project"
}

variable "region" {
  description = "AWS region where the ECS cluster and service will run."
  type        = string
}

variable "image" {
  description = "Full image URI (including tag) in ECR, for example: 123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest."
  type        = string
}

variable "task_cpu" {
  description = "CPU units for the Fargate task (for example: 256, 512, 1024). Must be a valid Fargate combination."
  type        = number
}

variable "task_memory" {
  description = "Memory (in MiB) for the Fargate task (for example: 512, 1024, 2048). Must be a valid Fargate combination."
  type        = number
}

variable "desired_count" {
  description = "Number of desired ECS service tasks."
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port the application container listens on (for example: 80 or 8080)."
  type        = number
}

variable "subnet_ids" {
  description = "Subnets where the ECS tasks will run (typically public subnets for the demo)."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups attached to the ECS tasks' ENIs."
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group where the ECS service will register its tasks."
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution role created by the IAM module."
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to Fargate tasks (true for demo in public subnets)."
  type        = bool
  default     = true
}

variable "log_group_retention_in_days" {
  description = "Retention period (in days) for CloudWatch Logs."
  type        = number
  default     = 7
}


