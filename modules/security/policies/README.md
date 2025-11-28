## modules/security/policies - policy-as-code for Terraform

This directory contains **policy-as-code** used to block unsafe infrastructure changes
in CI using [Conftest](https://www.conftest.dev/) (OPA/Rego) and optionally `tfsec`.

### Files

- `conftest/policy.rego`  
  Core Rego policies evaluated against Terraform **plan JSON** (`terraform show -json` output).
- `tfsec-ignore.hcl`  
  Optional tfsec ignore configuration (empty by default; any ignore must have a justification).

### Rego checks (policy.rego)

All rules are in the `main` package and emit human-readable `deny` messages.

- **Reject public S3 buckets**  
  - **Motivation:** Public S3 buckets are a common source of data leaks.  
  - **Rule:** Fails any `aws_s3_bucket` whose `acl` is `public-read`, `public-read-write`, or `website`.  
  - **Remediation:** Set `acl = "private"` and use `aws_s3_bucket_public_access_block` and bucket policies to control access.

- **Deny IAM wildcard actions/resources**  
  - **Motivation:** `"Action": "*"` or `"Resource": "*"` makes policies overly powerful and hard to audit.  
  - **Rule:** Fails `aws_iam_policy` and `aws_iam_role_policy` where any statement has `Action == "*" / ["*"]` or `Resource == "*" / ["*"]`.  
  - **Remediation:** Replace wildcards with the minimal set of IAM actions and resources required (specific ARNs or tagged resources).

- **Deny security groups with open DB ports**  
  - **Motivation:** Exposing Postgres on `5432` to the internet is unsafe.  
  - **Rule:** Fails any `aws_security_group` that allows ingress from `0.0.0.0/0` with a port range that includes `5432`.  
  - **Remediation:** Restrict ingress to the app/ECS security group only (no `0.0.0.0/0`), or to specific CIDR blocks if absolutely required.

- **Require tags (`project`, `env`)**  
  - **Motivation:** Tags are required for ownership, cost allocation, and security reviews.  
  - **Rule:** For resources that support `tags`, fails when `project` or `env` tags are missing.  
  - **Remediation:** Add `tags = { project = "infra-project", env = "<env>" }` (and any additional tags you enforce).

Each `deny` message includes a short remediation hint developers can follow.

### How to run Conftest locally

1. **Install Conftest**  
   Follow the instructions on the Conftest website, then verify:

   ```bash
   conftest --version
   ```

2. **Generate a Terraform plan JSON**  

   ```bash
   terraform plan -out=plan.tfplan
   terraform show -json plan.tfplan > plan.json
   ```

3. **Run Conftest against the plan**  

   ```bash
   conftest test plan.json -p modules/security/policies/conftest
   ```

4. **Deliberately create a violation to confirm failure**  
   - Example: set an S3 bucket `acl = "public-read"` or add an IAM policy with `Action = "*"`.  
   - Re-run `terraform plan` / `terraform show -json` and `conftest test`.  
   - You should see `deny` messages explaining what failed and how to fix it.

### CI integration (GitHub Actions example)

Below is an example of how to integrate Conftest into a Terraform plan job in CI.
You can adapt this into a workflow under `.github/workflows/` or reuse in `ci/github_actions/`:

```yaml
jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.7

      - name: Terraform init
        run: terraform -chdir=live/aws/dev init

      - name: Terraform plan
        run: |
          terraform -chdir=live/aws/dev plan -out=plan.tfplan
          terraform -chdir=live/aws/dev show -json plan.tfplan > plan.json

      - name: Install Conftest
        run: |
          curl -L https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_Linux_x86_64.tar.gz -o conftest.tar.gz
          tar xzf conftest.tar.gz
          sudo mv conftest /usr/local/bin/

      - name: Run policy checks (Conftest)
        run: conftest test live/aws/dev/plan.json -p modules/security/policies/conftest
```

- If **any policy fails**, the `terraform-plan` job will fail and the PR will be blocked.  
- This implements the requirement that unsafe infra (public S3, wildcard IAM, open DB ports, missing tags) cannot be merged.


