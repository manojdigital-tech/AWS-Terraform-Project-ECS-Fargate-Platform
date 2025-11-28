## Deploy runbook - dev environment

### Purpose

Document the exact, repeatable steps to deploy the dev environment infrastructure and
verify that the application is reachable through the ALB.

### Preconditions

- Terraform >= 1.5.7 installed (see `.terraform-version`).
- AWS CLI configured and able to assume the bootstrap/admin role for backend creation.
- Backend resources **not** yet created (first-time setup) or already created via this script.
- `AWS_PROFILE` (if used) is set to the correct profile.

### Steps

1. **Bootstrap backend (one-time per account/env)**

   ```bash
   ./scripts/bootstrap-backend.sh --env dev --region us-east-1 --account-id 123456789012
   ```

   - Confirms S3 state bucket, DynamoDB lock table, and KMS key/alias exist.

2. **Configure backend for dev**

   - Edit `live/aws/dev/backend.tf` and ensure:
     - `bucket` matches the `state_bucket` printed by the bootstrap script.
     - `dynamodb_table` matches the `lock_table` printed by the bootstrap script.
     - `kms_key_id` matches the `kms_alias` or key ARN printed by the script.

3. **Initialize Terraform (dev)**

   ```bash
   cd live/aws/dev
   terraform init
   ```

4. **Run static checks locally (from repo root)**

   ```bash
   cd /path/to/repo/root
   terraform fmt -recursive
   tflint --config .tflint.hcl
   tfsec .
   ```

5. **Plan and policy-as-code checks**

   ```bash
   terraform plan -var-file=dev.tfvars -out=plan.tfplan
   terraform show -json plan.tfplan > plan.json
   conftest test plan.json --policy ../../modules/security/policies/
   ```

6. **Apply (after approvals)**

   ```bash
   terraform apply plan.tfplan
   ```

7. **Smoke test**

   ```bash
   ALB_DNS=$(terraform output -raw alb_dns)
   curl -fsS "http://${ALB_DNS}/health" || (echo "health check failed" && exit 1)
   ```

### Notes

- For CI-driven applies, use `ci/github_actions/plan.yml` and `apply.yml` instead of running apply locally.
- Record any deviations or environment-specific steps here to keep the runbook accurate.


