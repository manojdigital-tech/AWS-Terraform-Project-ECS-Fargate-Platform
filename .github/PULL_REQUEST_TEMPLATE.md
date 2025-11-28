## Summary

<!-- Briefly describe what this PR changes (infra, modules, docs, CI, etc.). -->

## Checklist - Terraform hygiene

- [ ] **Formatting**: `terraform fmt -recursive` produces no diffs.
- [ ] **Validation**: `terraform validate` passes for all changed stacks.
- [ ] **Tflint**: `tflint --config .tflint.hcl` returns no errors. Any warnings are understood.
- [ ] **Tfsec**: `tfsec .` returns no critical/high findings; any low/medium are documented and suppressed with clear rationale if needed.

## Checklist - Policy-as-code & security

- [ ] **Conftest**: Generated plan JSON and ran:

  ```bash
  terraform plan -out=plan.tfplan -var-file=dev.tfvars
  terraform show -json plan.tfplan > plan.json
  conftest test plan.json --policy modules/security/policies/
  ```

  All Rego rules PASS.

- [ ] **No public S3**: No S3 buckets are public unless explicitly approved and documented.
- [ ] **IAM least privilege**: No new `"Action": "*"` or `"Resource": "*"` policies (except documented admin).
- [ ] **Network safety**: No DB ports (5432) exposed to `0.0.0.0/0`.
- [ ] **Required tags**: New resources support `tags` and include at least `project` and `env`.

## Checklist - CI & environment

- [ ] CI **plan job** passes (fmt, validate, tflint, tfsec, conftest, terraform plan).
- [ ] Plan artifact is attached to PR and reviewed.
- [ ] Any changes to **prod** paths were reviewed by SRE/Security (branch protection rules enforced).

## Notes / Risk / Rollback

- **Risk level**: <!-- low / medium / high -->
- **Rollback plan**: <!-- Describe how to revert or destroy resources if needed. -->


