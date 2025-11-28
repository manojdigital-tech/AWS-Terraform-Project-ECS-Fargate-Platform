// main.tf
// Creates an Application Load Balancer (ALB) for the application along with:
// - A target group for ECS tasks or EC2 instances.
// - A listener that routes HTTP traffic from port 80 on the ALB to the target group.
// This module focuses only on ALB + target group + listener; wiring ECS services to the
// target group is handled in a separate module.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

// Application Load Balancer in the public subnets.
resource "aws_lb" "this" {
  name               = "${var.project}-${var.environment}-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  idle_timeout               = 60
  enable_deletion_protection = false

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Target group that will receive traffic from the ALB listener.
// ECS services or EC2 instances will register as targets to this group.
resource "aws_lb_target_group" "this" {
  name     = "${var.project}-${var.environment}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    project = var.project
    env     = var.environment
  }
}

// Listener that accepts HTTP traffic on port 80 and forwards it to the target group.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}


