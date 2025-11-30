
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

  tags = var.tags
}

# ★ ここが「AWSCodeDeployRoleForECS を付ける」部分
resource "aws_iam_role_policy_attachment" "codedeploy_managed" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForECS"
}

###############################################
# CodeDeploy Application (ECS)
###############################################
resource "aws_codedeploy_app" "ecs" {
  name             = local.codedeploy_app_name
  compute_platform = "ECS"

  tags = var.tags
}

###############################################
# CodeDeploy Deployment Group (ECS Blue/Green)
###############################################
resource "aws_codedeploy_deployment_group" "ecs" {
  app_name              = aws_codedeploy_app.ecs.name
  deployment_group_name = local.codedeploy_deployment_group
  service_role_arn      = aws_iam_role.codedeploy.arn

  # ECS Service を CodeDeploy 管理下に置く
  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  # デプロイスタイル：ECS Blue/Green + トラフィック制御あり
  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  # Blue/Green の実際の動き（ALB + TG の切り替え）
  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  # ALB のリスナーとターゲットグループの紐付け
  load_balancer_info {
    target_group_pair_info {
      # 本番トラフィック（Blue→Green にスイッチ）
      prod_traffic_route {
        listener_arns = [var.production_listener_arn]
      }

      # テストトラフィック（検証用）
      test_traffic_route {
        listener_arns = [var.test_listener_arn]
      }

      # Blue / Green のターゲットグループ（名前で渡す）
      target_group {
        name = var.blue_target_group_name
      }

      target_group {
        name = var.green_target_group_name
      }
    }
  }

  # ロールバック設定（あれば便利だが、最初はシンプルに disabled）
  auto_rollback_configuration {
    enabled = false
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.codedeploy_managed
  ]
}
