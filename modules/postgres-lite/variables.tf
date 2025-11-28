// variables.tf
// Input variables for the postgres-lite module.
// These configure the EC2 instance, networking, and basic database settings
// for a minimal, demo-only Postgres deployment.

variable "environment" {
  description = "Environment name (for example: dev, stage, prod). Used for naming and tagging."
  type        = string
}

variable "project" {
  description = "Project tag value used for naming and tagging (for example: infra-project)."
  type        = string
  default     = "infra-project"
}

variable "vpc_id" {
  description = "ID of the VPC where the Postgres instance will be created."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Postgres EC2 instance (should be a private or app subnet in real setups; public for this demo is acceptable)."
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID used by ECS tasks/app. Only this SG will be allowed to reach Postgres on port 5432."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Postgres (for example: t3.micro, t4g.micro)."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for the Postgres instance (for example: Amazon Linux 2 in your region)."
  type        = string
}

variable "db_name" {
  description = "Name of the demo database to create."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username to create for the application."
  type        = string
  default     = "appuser"
}

variable "data_volume_size_gb" {
  description = "Size (in GiB) of the EBS volume used for Postgres data."
  type        = number
  default     = 20
}


