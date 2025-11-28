# .tflint.hcl
# TFLint configuration for this repository.
#
# Why this file exists:
# - Centralize TFLint configuration so everyone runs the same checks.
# - Enable the AWS plugin for provider-specific validations.
# - Allow rule customization over time (disable/enable or configure severities).

config {
  module = true
}

plugin "aws" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_s3_bucket_public_readable" {
  enabled = true
}

rule "aws_s3_bucket_public_readable_acls" {
  enabled = true
}


