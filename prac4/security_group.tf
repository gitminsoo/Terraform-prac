# ALB 보안 그룹 — 인터넷 → ALB 80 허용
resource "aws_security_group" "alb" {
  name        = "KMS-SG-ALB"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "KMS-SG-ALB" }
}

# WEB 서버 보안 그룹 — ALB SG → WEB 80 허용
resource "aws_security_group" "web" {
  name        = "KMS-SG-WEB"
  description = "Web Server Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # ALB SG에서만 수신
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "KMS-SG-WEB" }
}
