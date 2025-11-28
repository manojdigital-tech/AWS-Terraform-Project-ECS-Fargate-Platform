// main.tf
// Creates baseline IAM roles required by the platform:
// - ECS task execution role: allows tasks to pull images from ECR, write logs to CloudWatch,
//   and read secrets from Secrets Manager.
// - CI deploy role: assumable by a CI principal and limited (conceptually) to resources
//   tagged with the expected project and environment.
// - Developer read-only role: attached to the AWS managed ReadOnlyAccess policy.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  role_name_prefix = "${var.project}-${var.environment}"
}

// ------------------------------
// ECS task execution role
// ------------------------------

data "aws_iam_policy_document" "task_execution_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

// Role used by ECS tasks to interact with AWS services on startup/runtime.
resource "aws_iam_role" "task_execution_role" {
  name               = "${local.role_name_prefix}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Inline policy granting the minimal permissions for ECS task execution:
// - ECR: pull container images.
// - CloudWatch Logs: create log streams and put log events.
// - Secrets Manager: retrieve secrets (for example, DB credentials).
data "aws_iam_policy_document" "task_execution_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task_execution_inline" {
  name   = "${local.role_name_prefix}-ecs-task-execution-policy"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.task_execution_policy.json
}

// ------------------------------
// CI deploy role
// ------------------------------

// Trust policy allowing the CI principal to assume this role.
data "aws_iam_policy_document" "ci_deploy_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.ci_principal_arn]
    }
  }
}

resource "aws_iam_role" "ci_deploy_role" {
  name               = "${local.role_name_prefix}-ci-deploy"
  assume_role_policy = data.aws_iam_policy_document.ci_deploy_assume_role.json

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Policy for CI deploy role. In a real setup you would tailor the actions and
// resource ARNs to match the exact services you manage. Here we demonstrate the
// tag-based restriction using aws:ResourceTag for project/env.
data "aws_iam_policy_document" "ci_deploy_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "iam:PassRole",
      "logs:*",
      "s3:*",
      "dynamodb:*",
      "kms:*",
      "cloudwatch:*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/project"
      values   = [var.project]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/env"
      values   = [var.environment]
    }
  }
}

resource "aws_iam_role_policy" "ci_deploy_inline" {
  name   = "${local.role_name_prefix}-ci-deploy-policy"
  role   = aws_iam_role.ci_deploy_role.id
  policy = data.aws_iam_policy_document.ci_deploy_policy.json
}

// ------------------------------
// Developer read-only role
// ------------------------------

data "aws_iam_policy_document" "developer_readonly_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      // In practice you would scope this to a specific IAM user/role or SSO principal.
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_iam_role" "developer_readonly" {
  name               = "${local.role_name_prefix}-developer-readonly"
  assume_role_policy = data.aws_iam_policy_document.developer_readonly_assume_role.json

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Attach AWS managed ReadOnlyAccess policy to give read-only access to the account.
resource "aws_iam_role_policy_attachment" "developer_readonly_managed" {
  role       = aws_iam_role.developer_readonly.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


