# 타겟 그룹 — Health Check 경로 /
resource "aws_lb_target_group" "web" {
  name     = "KMS-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    # 기대 응답 코드
    matcher             = "200"
  }

  tags = { Name = "KMS-TG" }
}

# Application Load Balancer — 퍼블릭 서브넷에 배치
resource "aws_lb" "web" {
  name               = "KMS-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = { Name = "KMS-ALB" }
}

# HTTP 리스너 — 80 포트 → TG 포워딩
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
