# 共通設定
# リソース命名および環境識別に使用する
project     = "myapp"
environment = "dev"
region      = "ap-northeast-1"

# ネットワーク設定
vpc_cidr = "10.0.0.0/16"

# 利用するAZを明示的に指定する
azs = [
  "ap-northeast-1a",
  "ap-northeast-1c",
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
]

# dev環境のためNAT Gatewayは単一構成とする
single_nat = true

# 共通タグ
tags = {
  Owner     = "portfolio"
  Env       = "dev"
  ManagedBy = "Terraform"
  Project   = "myapp"
}

# ECSタスク設定
ecr_repository_name = "myapp"
image_tag           = "latest"

# 初期構築時のフォールバック
use_public_image = true

container_name = "app"
container_port = 80

cpu    = "256"
memory = "512"

desired_count = 1

# アプリケーション設定
environment_variables = {
  ENV       = "dev"
  LOG_LEVEL = "info"
}
