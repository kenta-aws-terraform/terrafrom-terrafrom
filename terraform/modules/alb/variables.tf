# 共通識別子
# リソース命名や環境識別に使用する
variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Network
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

# Tags
variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

# ALB Listener
variable "listener_port" {
  description = "ALB listener port (e.g., 80 or 443)"
  type        = number
  default     = 80
}

variable "test_listener_port" {
  description = "Test listener port for blue/green validation (e.g., 8080)"
  type        = number
  default     = 8080
}

# ヘルスチェック
variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}
