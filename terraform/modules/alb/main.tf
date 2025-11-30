#######################################
# ALB Security Group
#######################################

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security Group for ALB"
  vpc_id      = var.vpc_id

  # HTTP / HTTPS or listener_port
  ingress {
    from_port   = var.listener_port
    to_port     = var.listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound ALB port"
  }

  # Test listener
  ingress {
    from_port   = var.test_listener_port
    to_port     = var.test_listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound test listener port for blue/green"
  }

  # Outbound to anywhere
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

#######################################
# ALB 本体
#######################################

resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  idle_timeout       = 60

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

#######################################
# Target Groups (Blue / Green)
#######################################

resource "aws_lb_target_group" "blue" {
  name        = local.blue_tg_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"    # ←プロが絶対外さないポイント（Fargate 必須）

  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = "${local.blue_tg_name}"
  })
}

resource "aws_lb_target_group" "green" {
  name        = local.green_tg_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"    # ←必須

  health_check {
    path                = var.health_check_path
    matcher             = "200-399"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(local.common_tags, {
    Name = "${local.green_tg_name}"
  })
}

#######################################
# Listener (Production)
#######################################

resource "aws_lb_listener" "production" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn  # 初期は BLUE に向ける
  }

  # CodeDeploy が書き換える default_action を Terraform が戻さないようにする
  lifecycle {
    ignore_changes = [default_action]   # ←プロが必ず入れるハマりポイント回避
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-listener-production"
  })
}

#######################################
# Listener (Test Listener for Green test)
#######################################

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.test_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  lifecycle {
    ignore_changes = [default_action]   # ←同じく必要
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-listener-test"
  })
}
