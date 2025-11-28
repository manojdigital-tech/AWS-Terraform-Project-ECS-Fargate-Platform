// outputs.tf
// Output values from the bootstrap module so that calling stacks (for example, live/aws/dev)
// and CI/CD pipelines can reference the backend resources.

output "state_bucket" {
  description = "Name of the S3 bucket that stores Terraform remote state."
  value       = aws_s3_bucket.state_bucket.bucket
}

output "lock_table" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.lock_table.name
}

output "kms_key_id" {
  description = "ARN of the KMS key used to encrypt Terraform state and locks."
  value       = aws_kms_key.state.arn
}

output "kms_alias" {
  description = "KMS alias created for the Terraform state key."
  value       = aws_kms_alias.state_alias.name
}


