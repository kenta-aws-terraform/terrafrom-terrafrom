# 基本設定
# プロジェクトおよび環境識別に使用する
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stg/prod)"
  type        = string
}

# ECS Service
# CodeDeploy がデプロイ対象として操作する ECS サービス
variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS service name"
  type        = string
}

# ALB Listeners
# Blue / Green デプロイで使用する本番・検証用リスナー
variable "production_listener_arn" {
  description = "ALB production listener ARN"
  type        = string
}

variable "test_listener_arn" {
  description = "ALB test listener ARN"
  type        = string
}

# Target Groups
# Blue / Green デプロイで切り替えるターゲットグループ
variable "blue_target_group_name" {
  description = "Blue target group name"
  type        = string
}

variable "green_target_group_name" {
  description = "Green target group name"
  type        = string
}

# Tags
variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
