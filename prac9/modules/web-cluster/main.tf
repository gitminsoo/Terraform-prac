# Ubuntu 24.04 LTS AMI 동적 조회
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name   = "KMS-SG-ALB-${var.env}"
  vpc_id = var.vpc_id

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
  tags = { Name = "KMS-SG-ALB-${var.env}" }
}

# Web Server Security Group
resource "aws_security_group" "web" {
  name   = "KMS-SG-WEB-${var.env}"
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
  tags = { Name = "KMS-SG-WEB-${var.env}" }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "KMS-TG-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB
resource "aws_lb" "main" {
  name               = "KMS-ALB-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "KMS-ALB-${var.env}" }
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

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "KMS-LT-${var.env}-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>KMS Web Server - ${var.env}</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "KMS-WEB-${var.env}" }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "KMS-ASG-${var.env}"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.main.arn]
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}
