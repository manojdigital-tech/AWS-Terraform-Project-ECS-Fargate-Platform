// variables.tf
// Input variables for the bootstrap remote state + locking module.
// These values are provided by the caller (for example, live/aws/dev)
// to parameterize resource names, encryption, and tagging.

variable "environment" {
  description = "Short environment name (for example: dev, stage, prod). Used for naming and tagging."
  type        = string
}

variable "region" {
  description = "AWS region where the backend resources (S3, DynamoDB, KMS) will be created."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, used to keep the S3 state bucket name globally unique."
  type        = string
}


