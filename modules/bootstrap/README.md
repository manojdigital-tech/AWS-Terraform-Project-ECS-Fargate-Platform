## modules/bootstrap - remote state and locking

This module creates the minimal AWS resources required to support **secure Terraform remote state**:

- An **S3 bucket** to store Terraform state files.
- A **DynamoDB table** to provide state locking and prevent concurrent applies.
- A **KMS CMK + alias** to encrypt both the S3 bucket and DynamoDB table.

These resources are created **once per account/region** and reused by all other Terraform stacks in this repository.

### Inputs

- `environment` (string): Short environment name (for example: `dev`, `stage`, `prod`).
- `region` (string): AWS region where backend resources will be created.
- `account_id` (string): AWS account ID, used to make the S3 bucket name globally unique.

### Outputs

- `state_bucket`: Name of the S3 bucket that stores Terraform state.
- `lock_table`: Name of the DynamoDB table used for state locking.
- `kms_key_id`: ARN of the KMS key encrypting state and locks.
- `kms_alias`: KMS alias name for the state key.

### Example usage (from a root stack)

```hcl
module "bootstrap" {
  source = "../../modules/bootstrap"

  environment = "dev"
  region      = "us-east-1"
  account_id  = "123456789012"
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-dev-123456789012"
    key            = "infra-project/terraform/state/dev/root.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-infra-project-dev"
    encrypt        = true
  }
}
```


