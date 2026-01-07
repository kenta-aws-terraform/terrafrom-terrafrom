# IAM Role for CodeDeploy
# CodeDeploy サービスが ECS Blue/Green デプロイを実行するための IAM Role
resource "aws_iam_role" "codedeploy" {
  name = "${var.project}-${var.environment}-codedeploy-role"

  # CodeDeploy サービスが引き受けるための Assume Role Policy
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

# CodeDeploy（ECS）で必要となる AWS 管理ポリシーを付与
resource "aws_iam_role_policy_attachment" "codedeploy_managed" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

# CodeDeploy Application（ECS）
resource "aws_codedeploy_app" "ecs" {
  name             = local.codedeploy_app_name
  compute_platform = "ECS"

  tags = var.tags
}

# CodeDeploy Deployment Group（ECS Blue/Green）
resource "aws_codedeploy_deployment_group" "ecs" {
  app_name              = aws_codedeploy_app.ecs.name
  deployment_group_name = local.codedeploy_deployment_group
  service_role_arn      = aws_iam_role.codedeploy.arn

  # CodeDeploy 管理下に置く ECS サービス
  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  # Blue / Green デプロイ（トラフィック制御あり）
  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  # デプロイ成功後の旧タスク（Blue）の扱い
  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    # デプロイ待機時間は設けない
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  # ALB リスナー（本番 / テスト）と Target Group（Blue / Green）の関連付け
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

  # ロールバックは要件に応じて有効化する
  auto_rollback_configuration {
    enabled = false
  }

  tags = var.tags

  # IAM ポリシー付与後に作成する
  depends_on = [
    aws_iam_role_policy_attachment.codedeploy_managed
  ]
}
