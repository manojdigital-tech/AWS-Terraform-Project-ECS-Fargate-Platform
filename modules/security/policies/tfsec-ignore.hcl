# tfsec-ignore.hcl
# Optional configuration file for tfsec ignore rules.
#
# Intention:
# - Keep this file empty by default.
# - If a tfsec rule must be ignored, add a block here with a clear justification
#   and a link to an issue or ticket to fix it later.
#
# Example (do NOT leave this in place without justification):
#
# ignore "AWS002" {
#   # Justification: S3 bucket is public only in a non-production sandbox account
#   # and contains no sensitive data. See ticket SEC-123 for follow-up.
#   expiration = "2026-01-01"
# }


