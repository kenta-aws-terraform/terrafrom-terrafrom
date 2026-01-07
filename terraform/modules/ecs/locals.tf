locals {
  # リソース名を環境単位で一貫させるためのプレフィックス
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

  # ECS タスクで使用する CloudWatch Logs のロググループ名
  log_group_name = "/ecs/${local.name_prefix}"

  # ECS クラスターおよびサービス名
  ecs_cluster_name = "${local.name_prefix}-cluster"
  ecs_service_name = "${local.name_prefix}-service"

  # Fargate 用の assign_public_ip 設定値
  assign_public_ip_value = var.assign_public_ip ? "ENABLED" : "DISABLED"
}
