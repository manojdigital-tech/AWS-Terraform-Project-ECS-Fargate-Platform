// main.tf
// Creates a CloudWatch dashboard that visualizes key service metrics:
// - ALB 5xx errors and latency.
// - ECS service CPU and memory utilization.
// - Database connection count (custom metric).
// The dashboard body is defined in dashboard.json and templated with environment-specific values.

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
  dashboard_name = "${var.project}-${var.environment}-service-dashboard"
}

resource "aws_cloudwatch_dashboard" "service" {
  dashboard_name = local.dashboard_name

  dashboard_body = templatefile("${path.module}/dashboard.json", {
    environment         = var.environment
    project             = var.project
    alb_arn_suffix      = var.alb_arn_suffix
    cluster_name        = var.cluster_name
    service_name        = var.service_name
    db_metric_namespace = var.db_metric_namespace
    db_metric_name      = var.db_metric_name
  })
}


