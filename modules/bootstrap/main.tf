// main.tf
// Creates an S3 bucket for Terraform remote state, a DynamoDB table for state locks,
// and a KMS CMK used to encrypt both the state bucket and the lock table.
// This module is intended to be run once per account/region by an admin or bootstrap user
// before any other Terraform stacks start using the remote backend.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

// NOTE: The aws provider configuration (region, profile, assume_role, etc.)
// should be defined in the root module that calls this bootstrap module.

// KMS key used to encrypt the S3 state bucket and DynamoDB lock table.
resource "aws_kms_key" "state" {
  description             = "Terraform state KMS key for ${var.environment}"
  deletion_window_in_days = 30

  tags = {
    project = "infra-project"
    env     = var.environment
  }
}

// Human-friendly alias pointing at the KMS key so other tools / modules
// can reference it without hard-coding the key ID.
resource "aws_kms_alias" "state_alias" {
  name          = "alias/terraform-state-${var.environment}"
  target_key_id = aws_kms_key.state.key_id
}

// S3 bucket that stores Terraform state files for this account/environment.
// Bucket name includes account_id to ensure it is globally unique.
resource "aws_s3_bucket" "state_bucket" {
  bucket = "terraform-state-${var.environment}-${var.account_id}"

  tags = {
    project = "infra-project"
    env     = var.environment
  }
}

// Enable versioning so every change to the state file is kept as a previous
// version. This is important for recovery if a bad apply corrupts state.
resource "aws_s3_bucket_versioning" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

// Enforce server-side encryption with the KMS key created above.
// This ensures the Terraform state file is always encrypted at rest.
resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.state.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

// Block all forms of public access to the state bucket.
// Remote state must never be publicly readable.
resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// DynamoDB table used for Terraform state locking.
// This prevents two concurrent terraform apply operations from corrupting state.
resource "aws_dynamodb_table" "lock_table" {
  name         = "terraform-locks-infra-project-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.state.arn
  }

  tags = {
    project = "infra-project"
    env     = var.environment
  }
}


