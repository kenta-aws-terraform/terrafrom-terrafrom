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

  codedeploy_app_name           = "${local.name_prefix}-ecs-app"
  codedeploy_deployment_group   = "${local.name_prefix}-ecs-dg"
}
