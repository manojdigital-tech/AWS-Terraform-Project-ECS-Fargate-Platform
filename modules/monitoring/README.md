## modules/monitoring - dashboards and alarms

This module creates **CloudWatch dashboards and alarms** for the demo platform:

- A CloudWatch **dashboard** showing:
  - ALB 5xx errors and target response time (p95).
  - ECS service CPU and memory utilization.
  - DB connections (custom metric).
- A set of **CloudWatch alarms** wired to an SNS topic.
- An **SNS topic + email subscription** for alert notifications.

> Note: The DB connections widget and alarm assume a custom CloudWatch metric
> is being published (namespace `Custom/Postgres`, metric `db_connections` by default).

### Files

- `main.tf`: Creates the CloudWatch dashboard from `dashboard.json` using `templatefile`.
- `dashboard.json`: JSON definition of the dashboard widgets (ALB, ECS, DB).
- `alarms.tf`: Creates SNS topic, email subscription, and metric alarms.
- `variables.tf`: Inputs for environment, project, ALB, ECS, DB metrics, and alert email.

### Inputs

- `environment` (string): Environment name (for example: `dev`, `stage`, `prod`).
- `project` (string): Project tag value (default: `infra-project`).
- `alb_arn_suffix` (string): ARN suffix of the ALB (from `aws_lb.alb.arn_suffix`).
- `cluster_name` (string): ECS cluster name.
- `service_name` (string): ECS service name.
- `alarm_email` (string): Email address to subscribe to the SNS topic (default: `abhandari.2002@gmail.com`).
- `db_metric_namespace` (string): Namespace for DB connections metric (default: `Custom/Postgres`).
- `db_metric_name` (string): Metric name for DB connections (default: `db_connections`).

### Dashboard widgets

The dashboard includes:

- **ALB - 5xx Errors**: `AWS/ApplicationELB`, metric `HTTPCode_Target_5XX_Count`, dimension `LoadBalancer = alb_arn_suffix`.
- **ALB - Target Response Time**: `AWS/ApplicationELB`, metric `TargetResponseTime`, p95, dimension `LoadBalancer = alb_arn_suffix`.
- **ECS Service - CPU Utilization**: `AWS/ECS`, metric `CPUUtilization`, dimensions `ClusterName` and `ServiceName`.
- **ECS Service - Memory Utilization**: `AWS/ECS`, metric `MemoryUtilization`, dimensions `ClusterName` and `ServiceName`.
- **DB - Connections (custom metric)**: `${db_metric_namespace}/${db_metric_name}`, dimension `Environment = environment`.

### Alarms

Alarms (all send notifications to the SNS topic):

- `alb_5xx_high`: ALB target 5xx count ≥ 1 over 1 minute.
- `alb_latency_high`: ALB p95 target response time > 0.3 seconds.
- `ecs_cpu_high`: ECS service CPU utilization > 80% for 2 periods.
- `ecs_memory_high`: ECS service memory utilization > 80% for 2 periods.
- `db_connections_high`: DB connections metric > 100 for 2 periods.

### SNS topic and email subscription

- `aws_sns_topic.alerts`: SNS topic for monitoring alerts.
- `aws_sns_topic_subscription.email`: Email subscription to `alarm_email`.
  - On first `terraform apply`, AWS will send a confirmation email to this address.

### Example usage (from a root stack)

```hcl
module "monitoring" {
  source = "../../modules/monitoring"

  environment    = "dev"
  project        = "infra-project"
  alb_arn_suffix = module.alb.alb_arn_suffix
  cluster_name   = module.ecs_fargate.cluster_name
  service_name   = module.ecs_fargate.service_name
  alarm_email    = "abhandari.2002@gmail.com"
}
```


