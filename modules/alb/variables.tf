// variables.tf
// Input variables for the ALB module.
// These define which VPC and subnets to use, and basic naming / tagging.

variable "vpc_id" {
  description = "ID of the VPC where the ALB and target group will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID to attach to the ALB (for example, allowing inbound HTTP/HTTPS)."
  type        = string
}

variable "environment" {
  description = "Environment name used for tagging (for example: dev, stage, prod)."
  type        = string
}

variable "project" {
  description = "Project tag value used for naming and tagging (for example: infra-project)."
  type        = string
  default     = "infra-project"
}

variable "app_port" {
  description = "Port on which the ECS tasks / targets listen (defaults to 80)."
  type        = number
  default     = 80
}


