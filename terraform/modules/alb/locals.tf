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

  # CodeDeployによるBlue/Greenデプロイメントで使用するALBターゲットグループ名
  blue_tg_name  = "${local.name_prefix}-tg-blue"
  green_tg_name = "${local.name_prefix}-tg-green"
}
