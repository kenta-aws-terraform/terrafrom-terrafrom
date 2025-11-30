###############################################
# Data sources
###############################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

###############################################
# Local values
###############################################
locals {
  # ECR イメージ URI
  ecr_image_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repository_name}:${var.image_tag}"

  # 初回 apply 用の fallback
  final_image = var.use_public_image ? "nginx:alpine" : local.ecr_image_uri
}

###############################################
# IAM Role for ECS Task
###############################################
resource "aws_iam_role" "task_execution" {
  name = "${var.project}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

###############################################
# ECS Cluster
###############################################
resource "aws_ecs_cluster" "this" {
  name = "${var.project}-${var.environment}-cluster"

  tags = var.tags
}

###############################################
# Task Definition
###############################################
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.environment}-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name  = var.container_name
    image = local.final_image

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]

    environment = [
      for key, value in var.environment_variables : {
        name  = key
        value = value
      }
    ]
  }])

  tags = var.tags
}

###############################################
# ECS Service
###############################################
resource "aws_ecs_service" "app" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.alb_security_group_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.blue_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer,
    ]
  }

  tags = var.tags
}

