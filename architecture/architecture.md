# Architecture - ECS Fargate demo

Components:
- VPC: single VPC per env with public subnets for demo.
- ALB: public facing; routes traffic to ECS Fargate service target group.
- ECS Fargate: service running single task revision (container from ECR).
- ECR: private image registry with lifecycle policy.
- Postgres (postgres-lite): single EC2 instance with systemd-managed postgres for demo.
- State: S3 backend + DynamoDB lock; state bucket encrypted with KMS.
- Secrets: AWS Secrets Manager for DB credentials; KMS for encryption.
- Observability: CloudWatch metrics, logs, dashboards, and alarms.
