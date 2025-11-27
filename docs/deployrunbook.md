# Bootstrap backend (one-time per account)
./scripts/bootstrap-backend.sh --env dev --region us-east-1 --account-id 123456789012

# Plan (dev)
cd live/aws/dev
terraform init
terraform plan -var-file=dev.tfvars -out=plan.tfplan

# Apply (after approvals)
terraform apply plan.tfplan

# Smoke test
ALB_DNS=$(terraform output -raw alb_dns)
curl -fsS "http://${ALB_DNS}/health" || (echo "health check failed" && exit 1)