VPC: 10.20.0.0/16
Public subnets:
 - us-east-1a: 10.20.0.0/24
 - us-east-1b: 10.20.1.0/24

Backend:
 - S3 key: infra-project/terraform/state/<env>/<component>.tfstate
 - DynamoDB: terraform-locks-infra-project
 - KMS alias: alias/terraform-state-key-dev
