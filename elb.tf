# ==========================================================================================================================
# ALB
# ==========================================================================================================================

# alb [1] <- [n] listener [1] -> [1] target group [1] <- [n] target group attachment [n] -> [1] ec2 instance
resource "aws_lb" "alb" {
  name = "${var.project}-${var.environment}-alb"

  # インターネットからのアクセスを捌くのでinternalはfalse
  internal = false

  # ALB/NLBなどの指定
  load_balancer_type = "application"

  security_groups = [aws_security_group.web_security_group.id]
  subnets         = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1c.id]

  enable_deletion_protection = false

}

# HTTPをport:80で受け付ける
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    # そのまま転送するよ
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  # see: https://www.youtube.com/watch?v=2QHdvEHN050
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.existing_cerfiticate.arn

  default_action {
    # そのまま転送するよ
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}


# ==========================================================================================================================
# target group
# ==========================================================================================================================

# HTTPをport:3000に送る
resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.project}-${var.environment}-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name        = "${var.project}-${var.environment}-alb-target-group"
    Project     = var.project
    Environment = var.environment
  }
}

# アプリケーションサーバに送る
resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.application_server.id
}
