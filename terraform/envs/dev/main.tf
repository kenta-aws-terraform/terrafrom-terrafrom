# サービスインフラストラクチャ定義（ECS Fargate + Blue/Green）
# VPC / ALB / ECS(Fargate) / CodeDeploy を統合した Blue/Green デプロイ構成

# Network Module
# VPC、サブネット、ルート、NAT を定義（Public / Private を複数 AZ に分離）
module "network" {
  source = "../../modules/network"

  project     = var.project
  environment = var.environment
  region      = var.region

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # dev 環境はコスト優先のため NAT Gateway は単一構成
  single_nat = var.single_nat
  tags       = var.tags
}

# ALB Module (Blue/Green)
# インターネット入口となる ALB と Blue / Green 用 Target Group
module "alb" {
  source = "../../modules/alb"

  project     = var.project
  environment = var.environment

  # ALB は Public Subnet に配置（VPC / Subnet は network の出力を参照）
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  tags = var.tags

  # 適用順制御（network → alb）
  depends_on = [module.network]
}

# ECS Module (Fargate + ECS Exec)
# タスクは Private Subnet に配置し、外部公開は ALB に集約
module "ecs" {
  source = "../../modules/ecs"

  project     = var.project
  environment = var.environment

  private_subnet_ids = module.network.private_subnet_ids

  # ALB からの通信のみ許可
  alb_security_group_id = module.alb.alb_security_group_id

  # 初期状態は Blue Target Group（切替は CodeDeploy が制御）
  blue_target_group_arn = module.alb.blue_tg_arn

  ecr_repository_name = var.ecr_repository_name
  image_tag           = var.image_tag
  use_public_image    = var.use_public_image

  container_name = var.container_name
  container_port = var.container_port
  cpu            = var.cpu
  memory         = var.memory
  desired_count  = var.desired_count

  assign_public_ip      = false
  environment_variables = var.environment_variables

  tags = var.tags

  # 適用順制御（alb → ecs）
  depends_on = [module.alb]
}

# CodeDeploy Module (Blue/Green)
# Blue / Green デプロイ制御（本番 / テスト Listener と Target Group を連携）
module "codedeploy" {
  source = "../../modules/codedeploy"

  project     = var.project
  environment = var.environment

  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name

  production_listener_arn = module.alb.production_listener_arn
  test_listener_arn       = module.alb.test_listener_arn

  blue_target_group_name  = module.alb.blue_tg_name
  green_target_group_name = module.alb.green_tg_name

  tags = var.tags

  # 適用順制御（ecs → codedeploy）
  depends_on = [module.ecs]
}
