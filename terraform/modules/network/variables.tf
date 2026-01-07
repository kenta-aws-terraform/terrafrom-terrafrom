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

variable "region" {
  description = "AWS region (e.g. ap-northeast-1)"
  type        = string
}

# VPC
# VPC のアドレス設定
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

# Subnets & AZ
# Public / Private サブネットを AZ と 1:1 で対応させる
variable "azs" {
  description = "List of Availability Zones (e.g. [\"ap-northeast-1a\",\"ap-northeast-1c\"])"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# NAT Gateway
# 環境に応じて NAT Gateway を単一構成に切り替える
variable "single_nat" {
  description = "Use single NAT gateway for cost savings"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
