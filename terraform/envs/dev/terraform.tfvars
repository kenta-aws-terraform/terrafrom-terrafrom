############################################################
# 基本設定
############################################################
project     = "myapp"
environment = "dev"
region      = "ap-northeast-1"

############################################################
# Network (VPC)
############################################################
vpc_cidr = "10.0.0.0/16"

# 明示的にAZを指定（実務はこれが正しい）
azs = [
  "ap-northeast-1a",
  "ap-northeast-1c",
]

# Public Subnets（CIDR と AZ を1:1対応）
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
]

# Private Subnets（CIDR と AZ を1:1対応）
private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
]

# NAT Gateway：devは1つでコスト削減
single_nat = true

############################################################
# Tags (全モジュールに付与される)
############################################################
tags = {
  Owner     = "portfolio"
  Env       = "dev"
  ManagedBy = "Terraform"
  Project   = "myapp"
}

############################################################
# ECS Task (Application コンテナ)
############################################################

# 今回はリポジトリ名 / タグだけ
ecr_repository_name = "myapp"
image_tag           = "latest"

# 初回 apply 用の fallback（nginx:alpine を使う）
use_public_image = true

# コンテナ基本設定
container_name = "app"
container_port = 80

# Fargate Task サイズ
cpu    = "256"
memory = "512"

# ECS Service Desired Count
desired_count = 1

############################################################
# ECS Task の環境変数
############################################################
environment_variables = {
  ENV       = "dev"
  LOG_LEVEL = "info"
}
