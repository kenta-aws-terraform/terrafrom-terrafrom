###########################################
# Network Module
###########################################
module "network" {
  source = "../../modules/network"

  project     = var.project
  environment = var.environment
  region      = var.region

  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat = var.single_nat
  tags       = var.tags
}

###########################################
# ALB Module (Blue/Green)
###########################################
module "alb" {
  source = "../../modules/alb"

  project     = var.project
  environment = var.environment

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  tags = var.tags

  # ALB は VPC & Subnet が必要 → Network 完成後に依存
  depends_on = [module.network]
}

###########################################
# ECS Module (Fargate + ECS Exec)
###########################################
module "ecs" {
  source = "../../modules/ecs"

  project     = var.project
  environment = var.environment

  private_subnet_ids = module.network.private_subnet_ids

  # ALB → ECS の通信制御
  alb_security_group_id = module.alb.alb_security_group_id

  # ECS Blue 初期ターゲットグループ
  blue_target_group_arn = module.alb.blue_tg_arn

  # イメージ動的対応
  ecr_repository_name = var.ecr_repository_name
  image_tag           = var.image_tag
  use_public_image    = var.use_public_image

  # Task 定義項目
  container_name  = var.container_name
  container_port  = var.container_port
  cpu             = var.cpu
  memory          = var.memory
  desired_count   = var.desired_count

  assign_public_ip      = false
  environment_variables = var.environment_variables

  tags = var.tags

  # ECS は ALB ができてから適用されるべき
  depends_on = [module.alb]
}

###########################################
# CodeDeploy Module (Blue/Green)
###########################################
module "codedeploy" {
  source = "../../modules/codedeploy"

  project     = var.project
  environment = var.environment

  # ECS 情報
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name

  # ALB Listener
  production_listener_arn = module.alb.production_listener_arn
  test_listener_arn       = module.alb.test_listener_arn

  # Blue / Green TG
  blue_target_group_name  = module.alb.blue_tg_name
  green_target_group_name = module.alb.green_tg_name

  tags = var.tags

  # CodeDeploy は ECS が完成してから実行すべき
  depends_on = [module.ecs]
}
