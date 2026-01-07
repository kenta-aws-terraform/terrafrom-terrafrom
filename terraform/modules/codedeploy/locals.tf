locals {
  # リソース名を環境単位で一貫させるための共通プレフィックス
  name_prefix = "${var.project}-${var.environment}"

  # 全リソースに共通で付与するタグ
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # CodeDeploy
  codedeploy_app_name         = "${local.name_prefix}-ecs-app"
  codedeploy_deployment_group = "${local.name_prefix}-ecs-dg"
}
