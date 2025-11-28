// variables.tf
// Input variables for the monitoring module.
// These control how dashboards and alarms are wired to existing ALB, ECS, and DB components.

variable "environment" {
  description = "Environment name (for example: dev, stage, prod). Used for naming, tagging, and metric dimensions."
  type        = string
}

variable "project" {
  description = "Project tag value used for naming and tagging (for example: infra-project)."
  type        = string
  default     = "infra-project"
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer (for example: app/my-alb/1234567890abcdef)."
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster used for CPU/memory metrics."
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service used for CPU/memory metrics."
  type        = string
}

variable "alarm_email" {
  description = "Email address subscribed to the CloudWatch alarm SNS topic."
  type        = string
  default     = "abhandari.2002@gmail.com"
}

variable "db_metric_namespace" {
  description = "CloudWatch namespace for Postgres DB connections metric (custom or service-specific)."
  type        = string
  default     = "Custom/Postgres"
}

variable "db_metric_name" {
  description = "Metric name for DB connections in CloudWatch."
  type        = string
  default     = "db_connections"
}


