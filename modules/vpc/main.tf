// main.tf
// Creates the base networking for the application:
// - A VPC with a configurable CIDR range.
// - Public subnets in multiple AZs for the ALB and demo ECS tasks.
// - An Internet Gateway and route table to provide internet access for public subnets.
// - A baseline security group for app traffic that is intended to be used with an ALB
//   (ingress is controlled via security-group references, not 0.0.0.0/0).

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

// VPC that contains all networking for this environment.
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-${var.environment}-vpc"
    project = var.project
    env     = var.environment
  }
}

// Internet Gateway to provide outbound internet access for public subnets.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-${var.environment}-igw"
    project = var.project
    env     = var.environment
  }
}

// Route table for public subnets with a default route to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-${var.environment}-public-rt"
    project = var.project
    env     = var.environment
  }
}

// Create a public subnet in each AZ passed in via the azs variable.
resource "aws_subnet" "public" {
  for_each = {
    for idx, cidr in var.public_subnets :
    idx => {
      cidr = cidr
      az   = var.azs[idx]
    }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-${var.environment}-public-${each.value.az}"
    project = var.project
    env     = var.environment
    tier    = "public"
  }
}

// Associate each public subnet with the public route table so they can reach the internet.
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

// Baseline security group for application tasks in this VPC.
// Allow inbound HTTP(S) from ALB only; no direct SSH allowed.
resource "aws_security_group" "app_sg" {
  name        = "${var.project}-${var.environment}-app-sg"
  description = "Allow ALB to reach app tasks"
  vpc_id      = aws_vpc.main.id

  // We intentionally do not define any CIDR-based ingress here.
  // The ALB security group will be referenced via aws_security_group_rule
  // in the ECS / ALB modules to control which traffic is allowed.

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    // Egress allow all to permit outbound traffic to DB, S3, Secrets Manager, etc.
    // Access is further restricted by IAM policies.
  }

  tags = {
    Name    = "${var.project}-${var.environment}-app-sg"
    project = var.project
    env     = var.environment
  }
}


