###############################################
# IAM Role for CodeDeploy
###############################################
resource "aws_iam_role" "codedeploy" {
  name = "${var.project}-${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-codedeploy-role"
  })
}

# AWS 管理ポリシーを付与（ECS Blue/Green 用の標準ロール）
resource "aws_iam_role_policy_attachment" "codedeploy_ecs" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForECS"
}

###############################################
# CodeDeploy Application (ECS)
###############################################
resource "aws_codedeploy_app" "ecs" {
  name             = "${var.project}-${var.environment}-ecs-app"
  compute_platform = "ECS"

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-ecs-app"
  })
}

###############################################
# CodeDeploy Deployment Group (ECS Blue/Green)
###############################################
resource "aws_codedeploy_deployment_group" "ecs" {
  app_name              = aws_codedeploy_app.ecs.name
  deployment_group_name = "${var.project}-${var.environment}-ecs-dg"
  service_role_arn      = aws_iam_role.codedeploy.arn

  # AllAtOnce / Canary なども選べるが、まずは ECS 用デフォルト
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }

    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = var.deployment_ready_wait_time_in_minutes
    }
  }

  ########################################
  # Load Balancer / Listener / TG 設定
  ########################################
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.production_listener_arn]
      }

      test_traffic_route {
        listener_arns = [var.test_listener_arn]
      }

      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  ########################################
  # ECS Service 紐付け
  ########################################
  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-ecs-dg"
  })
}
