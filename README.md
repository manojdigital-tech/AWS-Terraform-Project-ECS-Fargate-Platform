# AWS Terraform Infrastructure – ECS Fargate Platform

## Purpose
Provision a production-aligned infrastructure stack using Terraform.  
Stack includes: VPC, ALB, ECS Fargate service, Postgres (EC2-hosted), ECR, Secrets Manager, CloudWatch metrics/logs/alarms, S3 remote state, DynamoDB locking, KMS encryption, IAM least-privilege, and CI/CD integration.

## Scope
Infrastructure only. Application images are provided via ECR.  
Terraform state stored remotely. CI applies infra using a restricted assume-role.  
Runtime stack is minimal but maintains real production patterns.

## Architecture Components
- VPC (public subnets for demo)
- ALB + target group
- ECS Cluster + Fargate Service + Task Definition
- ECR registry
- Postgres on EC2
- Secrets Manager (DB credentials)
- KMS CMK (state + secrets)
- S3 remote state + DynamoDB lock table
- CloudWatch logs, metrics, dashboards, alarms
- IAM roles: deploy role, exec role, developer read-only role, admin

## Repo Structure
docs/
modules/
live/aws/dev
live/aws/prod
ci/github-actions/
scripts/

pgsql
Copy code

## Pre-Deployment Requirements
- AWS account with administrative bootstrap access
- Terraform >= 1.5
- AWS CLI configured with MFA
- GitHub Actions OIDC or IAM user/role for CI
- Domain + Route53 hosted zone (optional)

## How to Deploy (dev)
./scripts/bootstrap-backend.sh --env dev --region us-east-1 --account-id <id>

cd live/aws/dev
terraform init
terraform plan -var-file=dev.tfvars -out=plan.tfplan
terraform apply plan.tfplan

ALB_DNS=$(terraform output -raw alb_dns)
curl -fsS "http://${ALB_DNS}/health"

shell
Copy code

## How to Destroy (dev)
cd live/aws/dev
terraform destroy -var-file=dev.tfvars -auto-approve
./scripts/cleanup.sh --env dev

markdown
Copy code

## Observability
- Application logs → CloudWatch Logs  
- ECS + ALB metrics → CloudWatch Metrics  
- Dashboards defined in monitoring module  
- Alarms routed to SNS

## Owners
- **Infra Owner:** Aashish  
- **Security Owner:** Aashish 
- **SRE Owner:** Aashish 
- **CI/CD Owner:** Aashish
