// main.tf
// Creates an ECR repository used to store container images for the application.
// A lifecycle policy is attached to automatically expire old images and keep
// only the last N images (configurable).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

// ECR repository for application container images.
resource "aws_ecr_repository" "this" {
  name = "${var.project}-${var.environment}-${var.repository_name}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Lifecycle policy that retains only the last N images and expires older ones.
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain last ${var.image_retention_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.image_retention_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}


