// outputs.tf
// Output values from the VPC module so other modules (ALB, ECS, DB, etc.)
// can reference the VPC, public subnets, and baseline security group.

output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "app_security_group_id" {
  description = "ID of the baseline app security group."
  value       = aws_security_group.app_sg.id
}


