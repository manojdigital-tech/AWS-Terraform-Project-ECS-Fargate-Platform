## modules/ecr - container registry

This module creates an **ECR repository** to store container images for the application,
with a lifecycle policy to automatically delete older images.

### Inputs

- `repository_name` (string): Base name for the repository (for example: `app-api`).
- `image_retention_count` (number): How many images to retain (default: `10`).
- `environment` (string): Environment name (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).

### Outputs

- `repository_url`: URL of the ECR repository.
- `registry_id`: Registry ID that owns the ECR repository.

### Example usage (from a root stack)

```hcl
module "ecr" {
  source = "../../modules/ecr"

  repository_name       = "app-api"
  image_retention_count = 20
  environment           = "dev"
  project               = "infra-project"
}
```


