## modules/alb - application load balancer

This module creates an **Application Load Balancer (ALB)** in public subnets, plus:

- A **target group** for ECS tasks or EC2 instances.
- An **HTTP listener** on port 80 forwarding to the target group.

### Inputs

- `vpc_id` (string): ID of the VPC where the ALB and target group will live.
- `public_subnet_ids` (list(string)): Public subnet IDs for the ALB.
- `alb_security_group_id` (string): Security group ID attached to the ALB.
- `environment` (string): Environment name (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).
- `app_port` (number): Port the application listens on (default: `80`).

### Outputs

- `alb_dns_name`: DNS name of the ALB (used in runbooks and smoke tests).
- `target_group_arn`: ARN of the target group that ECS services will register with.

### Example usage (from a root stack)

```hcl
module "alb" {
  source = "../../modules/alb"

  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  alb_security_group_id = aws_security_group.alb_sg.id
  environment          = "dev"
  project              = "infra-project"
  app_port             = 80
}
```


