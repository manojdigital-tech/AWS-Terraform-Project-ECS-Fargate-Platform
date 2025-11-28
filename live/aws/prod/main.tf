// main.tf
// Root Terraform configuration for the AWS prod environment.
// Mirrors the dev stack but with prod-specific variables.

module "vpc" {
  source = "../../../modules/vpc"

  project        = var.project
  environment    = var.environment
  cidr_vpc       = var.cidr_vpc
  public_subnets = var.public_subnets
  azs            = var.azs
}

module "iam" {
  source = "../../../modules/iam"

  project          = var.project
  environment      = var.environment
  ci_principal_arn = "arn:aws:iam::${var.account_id}:role/github-actions-prod" # TODO: replace with real CI principal ARN
}

module "ecr" {
  source = "../../../modules/ecr"

  project               = var.project
  environment           = var.environment
  repository_name       = "app"
  image_retention_count = 50
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "ALB security group allowing inbound HTTP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Public HTTP access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    project = var.project
    env     = var.environment
  }
}

module "alb" {
  source = "../../../modules/alb"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = aws_security_group.alb_sg.id
  app_port              = var.container_port
}

module "ecs_fargate" {
  source = "../../../modules/ecs_fargate"

  project                 = var.project
  environment             = var.environment
  region                  = var.region
  image                   = var.image
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  desired_count           = var.desired_count
  container_port          = var.container_port
  subnet_ids              = module.vpc.public_subnet_ids
  security_group_ids      = [module.vpc.app_security_group_id]
  target_group_arn        = module.alb.target_group_arn
  task_execution_role_arn = module.iam.task_execution_role_arn
}

module "postgres_lite" {
  source = "../../../modules/postgres-lite"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnet_ids[0]
  app_security_group_id = module.vpc.app_security_group_id
  instance_type         = var.db_instance_type
  ami_id                = var.db_ami_id
  db_name               = var.db_name
  db_username           = var.db_username
  data_volume_size_gb   = var.db_data_volume_size_gb
}

module "monitoring" {
  source = "../../../modules/monitoring"

  project        = var.project
  environment    = var.environment
  alb_arn_suffix = module.alb.alb_arn_suffix
  cluster_name   = module.ecs_fargate.cluster_name
  service_name   = module.ecs_fargate.service_name
  alarm_email    = var.alarm_email
}


