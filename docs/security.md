# Security Controls

## Data Classification
- Service handles general application data and non-regulated user metadata.
- No PII/PCI unless extended. Treat DB credentials and secrets as confidential.

## Secrets Management
- All secrets stored in AWS Secrets Manager.
- Encryption enforced using KMS CMK: alias/service-key-<env>.
- No plaintext secrets in Terraform code or tfvars.
- ECS tasks retrieve secrets using task execution role with GetSecretValue only.

## Encryption Standards
- S3 state bucket: SSE-KMS (CMK alias/terraform-state-key-<env>).
- DynamoDB table: server-side encryption enabled.
- EBS volume for Postgres EC2 instance encrypted with KMS.
- TLS termination at ALB when HTTPS is configured (optional).

## IAM Model (Least Privilege)
| Principal | Purpose | Allowed Actions | Resource Scope |
|----------|----------|----------------|----------------|
| Deploy Role | Terraform apply from CI | CRUD on project resources, tag-restricted | Only resources tagged project=<project>, env=<env> |
| CI Role | Run plan/apply | sts:AssumeRole → DeployRole, state read/write | S3 state bucket, DynamoDB lock |
| Exec Role (Task) | Run container | ecr:GetAuthToken, ecr:BatchGetImage, secretsmanager:GetSecretValue, logs:CreateLogStream/PutLogEvents | Only required ARNs |
| Developer ReadOnly Role | Inspect infra | Describe*/List* only | Entire account |
| Admin Role | Rare operations, break-glass | Full action set | Restricted to two MFA-enforced principals |

## Network Controls
- ALB public. ECS tasks allowed inbound only from ALB target group.
- Postgres EC2 allows inbound only from ECS task ENIs on port 5432.
- No `0.0.0.0/0` inbound to DB or ECS tasks.
- S3 public access block enforced.

## Policy-as-Code Requirements
Reject merges if any rule fails:
- IAM policies containing `"Action": "*"` or `"Resource": "*"` (except admin role).
- Any security group allowing `0.0.0.0/0` to 5432.
- Any S3 bucket without SSE-KMS.
- Any resource missing mandatory tags: project, env, owner.

## Logging and Audit
- CloudTrail enabled and storing API logs.
- CloudWatch Logs receive app logs, container logs, and DB logs.
- IAM changes tracked through CloudTrail and IAM Access Analyzer.

## Access Control
- MFA required for human principals.
- CI uses OIDC or specific IAM role with limited session duration.
- Session Manager used for EC2 access; SSH disabled for demo.

## Rotation and Key Management
- CMK rotation: annual.
- DB password rotation: Secrets Manager manual rotation allowed.
- IAM access keys prohibited except break-glass accounts.

