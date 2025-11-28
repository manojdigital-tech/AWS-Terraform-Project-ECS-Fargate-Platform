## modules/ecs_fargate - run app on Fargate

This module creates everything needed to run the application on **ECS Fargate** and
attach it to the existing ALB:

- An **ECS cluster**.
- A **task definition** that references the container image in ECR.
- An **ECS Fargate service** using `awsvpc` networking.
- A **CloudWatch Logs log group** for container logs.
- Integration with the **ALB target group** via the service `load_balancer` block.

> Note: This module assumes the image is already built and pushed to ECR.

### Inputs

- `environment` (string): Environment name (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).
- `region` (string): AWS region where ECS runs.
- `image` (string): Full image URI (including tag), for example `123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest`.
- `task_cpu` (number): Task CPU units (valid Fargate value, for example `256`, `512`, `1024`).
- `task_memory` (number): Task memory in MiB (valid Fargate value, for example `512`, `1024`).
- `desired_count` (number): Desired number of tasks (default: `1`).
- `container_port` (number): Port the app listens on (for example: `80` or `8080`).
- `subnet_ids` (list(string)): Subnets where tasks run (public subnets for the demo).
- `security_group_ids` (list(string)): Security groups for the tasks' ENIs.
- `target_group_arn` (string): ARN of the ALB target group.
- `task_execution_role_arn` (string): ARN of the ECS task execution role from the IAM module.
- `assign_public_ip` (bool): Whether to assign a public IP (`true` for demo).
- `log_group_retention_in_days` (number): CloudWatch Logs retention (default: `7`).

### Outputs

- `cluster_name`: Name of the ECS cluster.
- `service_name`: Name of the ECS service.
- `service_arn`: ARN of the ECS service.
- `task_definition_arn`: ARN of the ECS task definition.
- `log_group_name`: Name of the CloudWatch log group.

### Example usage (from a root stack)

```hcl
module "ecs_fargate" {
  source = "../../modules/ecs_fargate"

  environment            = "dev"
  project                = "infra-project"
  region                 = "us-east-1"
  image                  = module.ecr.repository_url != "" ? "${module.ecr.repository_url}:latest" : "123456789012.dkr.ecr.us-east-1.amazonaws.com/app:latest"
  task_cpu               = 256
  task_memory            = 512
  desired_count          = 1
  container_port         = 80
  subnet_ids             = module.vpc.public_subnet_ids
  security_group_ids     = [module.vpc.app_security_group_id]
  target_group_arn       = module.alb.target_group_arn
  task_execution_role_arn = module.iam.task_execution_role_arn
}
```

### Local test flow (manual, outside Terraform)

1. **Build a simple image with `/health` endpoint** (for example, tiny Python Flask or Nginx container).
2. **Push the image to ECR** created by `modules/ecr`.
3. **Set the `image` variable** to the exact `repository_url:tag` you pushed.
4. Run `terraform plan` to confirm the ECS service and ALB wiring look correct.


