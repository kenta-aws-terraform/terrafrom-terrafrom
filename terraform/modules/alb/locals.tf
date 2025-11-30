locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  # Blue/Green 用ターゲットグループ名
  blue_tg_name  = "${local.name_prefix}-tg-blue"
  green_tg_name = "${local.name_prefix}-tg-green"
}
