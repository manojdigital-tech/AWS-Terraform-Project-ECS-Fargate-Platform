## modules/iam - baseline IAM roles

This module creates **baseline IAM roles** required by the platform:

- **ECS task execution role** – lets tasks pull images from ECR, write logs to CloudWatch Logs, and read secrets from Secrets Manager.
- **CI deploy role** – assumable by a CI principal and conceptually restricted to resources tagged with the expected `project` and `environment`.
- **Developer read-only role** – attached to the AWS managed `ReadOnlyAccess` policy.

### Inputs

- `environment` (string): Environment name (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).
- `ci_principal_arn` (string): ARN of the CI principal that is allowed to assume the deploy role.

### Outputs

- `task_execution_role_arn`: ARN of the ECS task execution role.
- `ci_deploy_role_arn`: ARN of the CI deploy role.
- `developer_readonly_role_arn`: ARN of the developer read-only role.

### Example usage (from a root stack)

```hcl
module "iam" {
  source = "../../modules/iam"

  environment     = "dev"
  project         = "infra-project"
  ci_principal_arn = "arn:aws:iam::123456789012:role/github-actions"
}
```


