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

  # CloudWatch Logs group name for ECS tasks
  log_group_name = "/ecs/${local.name_prefix}"

  # ECS cluster & service names
  ecs_cluster_name = "${local.name_prefix}-cluster"
  ecs_service_name = "${local.name_prefix}-service"

  # Fargate の assign_public_ip 用（FARGATE は文字列指定）
  assign_public_ip_value = var.assign_public_ip ? "ENABLED" : "DISABLED"
}
