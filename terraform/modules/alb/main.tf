# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security Group for ALB"
  vpc_id      = var.vpc_id

  # 本番リスナー用のインバウンド
  ingress {
    from_port   = var.listener_port
    to_port     = var.listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic to ALB listener"
  }

  # Blue/Greenデプロイ時の検証用リスナー
  ingress {
    from_port   = var.test_listener_port
    to_port     = var.test_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic to test listener"
  }

  # ALBからのアウトバウンド通信を許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

# Application Load Balancer
resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  idle_timeout = 60

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

# Target Group(Blue)
resource "aws_lb_target_group" "blue" {
  name        = local.blue_tg_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" #ECS Fargate用

  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = local.blue_tg_name
  })
}

# Target Group(Green)
resource "aws_lb_target_group" "green" {
  name        = local.green_tg_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" #ECS Fargate用

  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = local.green_tg_name
  })
}

# Listener(Production)
resource "aws_lb_listener" "production" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  # 初期状態ではBlue側へトラフィックを転送
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  # CodeDeployによる切り替えをTerraformが上書きしないよう制御
  lifecycle {
    ignore_changes = [default_action]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-listener-production"
  })
}

# Listener(Test)
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.test_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-listener-test"
  })
}
