// variables.tf
// Input variables for the ECR module.
// These values control the repository name and lifecycle configuration.

variable "repository_name" {
  description = "Name of the ECR repository (for example: app-api)."
  type        = string
}

variable "image_retention_count" {
  description = "Number of images to retain in the ECR repository lifecycle policy."
  type        = number
  default     = 10
}

variable "environment" {
  description = "Environment name used for tagging (for example: dev, stage, prod)."
  type        = string
}

variable "project" {
  description = "Project tag value used for tagging (for example: infra-project)."
  type        = string
  default     = "infra-project"
}


