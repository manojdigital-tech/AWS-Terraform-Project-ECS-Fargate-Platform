## Teardown runbook - dev environment

### Purpose

Document the steps to safely destroy the dev environment infrastructure and clean up
supporting resources without impacting other environments.

### Preconditions

- You understand which resources are **shared** (for example, bootstrap backend) and must not be destroyed accidentally.
- You are using the correct AWS credentials for the dev account.
- No critical testing is in progress that depends on dev.

### Steps

1. **Review current state and resources**

   - Inspect the Terraform state and AWS console to confirm what will be destroyed.

2. **Plan destroy (dev)**

   ```bash
   cd live/aws/dev
   terraform plan -destroy -var-file=dev.tfvars -out=destroy.tfplan
   ```

   - Review the plan output carefully; ensure only dev resources are listed.

3. **Apply destroy plan**

   ```bash
   terraform apply destroy.tfplan
   ```

4. **Post-destroy verification**

   - Confirm that:
     - ECS services, ALB, and Postgres-lite EC2 instance are gone.
     - Security groups, IAM roles, and other per-env resources are removed.
   - The **backend resources** (state bucket, lock table, KMS key) remain intact unless you are decommissioning the entire project.

5. **Optional: Backend cleanup (project decommission only)**

   If you are permanently decommissioning the project and no other environments use the backend:

   - Empty the S3 state bucket.
   - Delete the DynamoDB lock table.
   - Schedule deletion of the KMS key (respecting the destruction window).

### Dry-run / Safety checks

- You can simulate destroy without applying:

  ```bash
  terraform plan -destroy -var-file=dev.tfvars
  ```

- Ensure there is no `prevent_destroy = true` on resources you expect to remove (or update configuration before destroy).


