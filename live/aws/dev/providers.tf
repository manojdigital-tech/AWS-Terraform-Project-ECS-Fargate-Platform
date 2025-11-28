// providers.tf
// Configures the AWS provider for the dev environment.
// Credentials are supplied via environment variables, shared config, or
// GitHub Actions OIDC role (see CI workflows).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Optional: default tags applied to all resources.
  default_tags {
    tags = {
      project = var.project
      env     = var.environment
    }
  }
}


