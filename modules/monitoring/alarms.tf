// alarms.tf
// Creates CloudWatch alarms for key service metrics and sends notifications
// to an SNS topic with an email subscription.
// Alarms cover:
// - ALB 5xx errors
// - ALB latency (p95)
// - ECS service CPU and memory utilization
// - DB connections (custom metric)

locals {
  alarm_name_prefix = "${var.project}-${var.environment}"
}

// SNS topic receiving all monitoring alerts.
resource "aws_sns_topic" "alerts" {
  name = "${local.alarm_name_prefix}-alerts"

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Email subscription used for testing alarms.
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

// ------------------------------
// ALB alarms
// ------------------------------

resource "aws_cloudwatch_metric_alarm" "alb_5xx_high" {
  alarm_name          = "${local.alarm_name_prefix}-alb-5xx-high"
  alarm_description   = "ALB target 5xx errors are high."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    project = var.project
    env     = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_latency_high" {
  alarm_name        = "${local.alarm_name_prefix}-alb-latency-high"
  alarm_description = "ALB target response time (p95) is high."

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p95"
  threshold           = 0.3 // ~300ms

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    project = var.project
    env     = var.environment
  }
}

// ------------------------------
// ECS alarms
// ------------------------------

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name        = "${local.alarm_name_prefix}-ecs-cpu-high"
  alarm_description = "ECS service CPU utilization is high."

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    project = var.project
    env     = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name        = "${local.alarm_name_prefix}-ecs-memory-high"
  alarm_description = "ECS service memory utilization is high."

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    project = var.project
    env     = var.environment
  }
}

// ------------------------------
// DB connections alarm (custom metric)
// ------------------------------

resource "aws_cloudwatch_metric_alarm" "db_connections_high" {
  alarm_name        = "${local.alarm_name_prefix}-db-connections-high"
  alarm_description = "Database connections (custom metric) are high."

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = var.db_metric_name
  namespace           = var.db_metric_namespace
  period              = 60
  statistic           = "Average"
  threshold           = 100

  dimensions = {
    Environment = var.environment
  }

  treat_missing_data = "notBreaching"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  tags = {
    project = var.project
    env     = var.environment
  }
}


