// outputs.tf
// Output values from the ALB module so other modules and runbooks
// can discover the ALB endpoint and target group.

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group used by the ALB."
  value       = aws_lb_target_group.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB, used for CloudWatch metric dimensions."
  value       = aws_lb.this.arn_suffix
}



