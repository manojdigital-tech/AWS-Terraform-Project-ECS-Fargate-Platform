// policy.rego
// Conftest / OPA policies to enforce security guardrails on Terraform plans.
// These rules are evaluated against the JSON output of:
//   terraform show -json plan.tfplan > plan.json
//
// Motivation:
// - Prevent accidentally exposing S3 buckets to the public internet.
// - Block IAM policies that use wildcards for Action/Resource.
// - Block security groups that expose database ports to 0.0.0.0/0.
// - Require standard tags (project, env) on taggable resources for ownership and cost tracking.
//
// Each rule includes remediation guidance in the deny message.

package main

default deny = []

##########
## Helpers
##########

resource_changes[rc] {
  rc := input.resource_changes[_]
}

has_tags(obj) {
  obj.tags
}

has_tag(obj, key) {
  obj.tags[key]
}

is_create_or_update(rc) {
  rc.change.actions[_] == "create"
} {
  rc.change.actions[_] == "update"
}

###############
## S3 - no public buckets
###############

s3_public_buckets[rc] {
  rc := resource_changes[_]
  rc.type == "aws_s3_bucket"
  is_create_or_update(rc)

  after := rc.change.after

  # Simple check: ACL is explicitly public.
  acl := lower(after.acl)
  acl == "public-read" or
  acl == "public-read-write" or
  acl == "website"
}

deny[msg] {
  rc := s3_public_buckets[_]
  msg := sprintf("S3 bucket %s has a public ACL. Set acl = \"private\" and use aws_s3_bucket_public_access_block / bucket policies to prevent public access.", [rc.address])
}

########################
## IAM - no wildcard actions/resources
########################

iam_policies_with_wildcards[rc] {
  rc := resource_changes[_]
  rc.type == "aws_iam_policy"
  is_create_or_update(rc)

  policy_json := rc.change.after.policy
  policy := json.unmarshal(policy_json)

  stmt := policy.Statement[_]
  action := stmt.Action
  action == "*" or action == ["*"]
}

iam_policies_with_wildcard_resources[rc] {
  rc := resource_changes[_]
  rc.type == "aws_iam_policy"
  is_create_or_update(rc)

  policy_json := rc.change.after.policy
  policy := json.unmarshal(policy_json)

  stmt := policy.Statement[_]
  res := stmt.Resource
  res == "*" or res == ["*"]
}

inline_iam_policies_with_wildcards[rc] {
  rc := resource_changes[_]
  rc.type == "aws_iam_role_policy"
  is_create_or_update(rc)

  policy_json := rc.change.after.policy
  policy := json.unmarshal(policy_json)

  stmt := policy.Statement[_]
  action := stmt.Action
  action == "*" or action == ["*"]
}

inline_iam_policies_with_wildcard_resources[rc] {
  rc := resource_changes[_]
  rc.type == "aws_iam_role_policy"
  is_create_or_update(rc)

  policy_json := rc.change.after.policy
  policy := json.unmarshal(policy_json)

  stmt := policy.Statement[_]
  res := stmt.Resource
  res == "*" or res == ["*"]
}

deny[msg] {
  rc := iam_policies_with_wildcards[_]
  msg := sprintf("IAM policy %s uses Action \"*\". Scope actions down to the minimal set required.", [rc.address])
}

deny[msg] {
  rc := iam_policies_with_wildcard_resources[_]
  msg := sprintf("IAM policy %s uses Resource \"*\". Restrict resources to specific ARNs or tagged resources.", [rc.address])
}

deny[msg] {
  rc := inline_iam_policies_with_wildcards[_]
  msg := sprintf("Inline IAM role policy %s uses Action \"*\". Scope actions down to the minimal set required.", [rc.address])
}

deny[msg] {
  rc := inline_iam_policies_with_wildcard_resources[_]
  msg := sprintf("Inline IAM role policy %s uses Resource \"*\". Restrict resources to specific ARNs or tagged resources.", [rc.address])
}

#############################
## Security groups - no open DB ports
#############################

sg_open_db_to_world[rc] {
  rc := resource_changes[_]
  rc.type == "aws_security_group"
  is_create_or_update(rc)

  after := rc.change.after
  ingress := after.ingress[_]

  cidr := ingress.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  # DB port 5432 is within the ingress range.
  ingress.from_port <= 5432
  ingress.to_port >= 5432
}

deny[msg] {
  rc := sg_open_db_to_world[_]
  msg := sprintf("Security group %s exposes PostgreSQL (5432) to 0.0.0.0/0. Restrict ingress to the app/ECS security group only.", [rc.address])
}

##########################
## Tags - require project/env
##########################

resources_missing_tags[rc] {
  rc := resource_changes[_]
  is_create_or_update(rc)
  after := rc.change.after

  has_tags(after)

  not has_tag(after, "project")
} {
  rc := resource_changes[_]
  is_create_or_update(rc)
  after := rc.change.after

  has_tags(after)

  not has_tag(after, "env")
}

deny[msg] {
  rc := resources_missing_tags[_]
  msg := sprintf("Resource %s is missing required tags (project and/or env). Add tags = { project = \"infra-project\", env = \"<env>\" }.", [rc.address])
}


