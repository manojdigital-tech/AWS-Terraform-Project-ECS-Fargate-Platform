## modules/vpc - base networking

This module creates the **base VPC networking** for the application:

- A VPC with DNS support enabled.
- Public subnets across multiple availability zones.
- An Internet Gateway and a public route table with a default route to the internet.
- A baseline security group for application tasks, designed to be paired with an ALB.

### Inputs

- `cidr_vpc` (string): CIDR block for the VPC (for example: `10.20.0.0/16`).
- `public_subnets` (list(string)): List of CIDR blocks for public subnets (one per AZ).
- `azs` (list(string)): List of availability zones corresponding to `public_subnets`.
- `environment` (string): Environment name used for tagging (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).

### Outputs

- `vpc_id`: ID of the created VPC.
- `vpc_cidr_block`: CIDR block for the VPC.
- `public_subnet_ids`: IDs of the public subnets.
- `app_security_group_id`: ID of the baseline app security group.

### Example usage (from a root stack)

```hcl
module "vpc" {
  source = "../../modules/vpc"

  cidr_vpc       = "10.20.0.0/16"
  public_subnets = ["10.20.0.0/24", "10.20.1.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
  environment    = "dev"
  project        = "infra-project"
}
```


