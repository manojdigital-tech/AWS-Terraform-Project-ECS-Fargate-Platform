// variables.tf
// Input variables for the IAM module.
// These control environment / project tagging and the CI principal that is
// allowed to assume the deploy role.

variable "environment" {
  description = "Environment name (for example: dev, stage, prod). Used for role names and tags."
  type        = string
}

variable "project" {
  description = "Project tag value used for IAM role names and tags (for example: infra-project)."
  type        = string
  default     = "infra-project"
}

variable "ci_principal_arn" {
  description = "ARN of the CI principal (for example: GitHub OIDC role or IAM user) that can assume the deploy role."
  type        = string
}


