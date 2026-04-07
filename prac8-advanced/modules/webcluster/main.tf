# modules/web-cluster/main.tf

# Ubuntu 24.04 LTS AMI 동적 조회
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ALB 보안 그룹 (인터넷 → ALB)
resource "aws_security_group" "alb" {
  name   = "${var.project_name}-SG-ALB"
  vpc_id = var.vpc_id  # 변수에서 참조

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

  tags = { Name = "${var.project_name}-SG-ALB" }
}

# 웹 서버 보안 그룹 (ALB → EC2)
resource "aws_security_group" "web" {
  name   = "${var.project_name}-SG-WEB"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-SG-WEB" }
}

# 타겟 그룹
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids  # 변수에서 참조
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# 론치 템플릿
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-LT"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>${var.project_name} Web Server</h1><p>$(hostname -f)</p>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-WEB" }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-ASG"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids  # 변수에서 참조

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.main.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ASG"
    propagate_at_launch = true
  }
}
