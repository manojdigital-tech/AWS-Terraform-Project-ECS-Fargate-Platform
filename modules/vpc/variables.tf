// variables.tf
// Input variables for the VPC module.
// These define the CIDR range for the VPC and the public subnets / AZ mapping
// that will be used by the ALB and ECS Fargate tasks.

variable "cidr_vpc" {
  description = "CIDR block for the VPC (for example: 10.20.0.0/16)."
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks (for example: [\"10.20.0.0/24\", \"10.20.1.0/24\"])."
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones that correspond to the public_subnets list."
  type        = list(string)
}

variable "environment" {
  description = "Short environment name used for tagging (for example: dev, stage, prod)."
  type        = string
}

variable "project" {
  description = "Project tag value used to group resources (for example: infra-project)."
  type        = string
  default     = "infra-project"
}


