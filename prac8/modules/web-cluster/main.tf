
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "KMS-VPC-${var.env}" }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "KMS-IGW-${var.env}" }
}

# 퍼블릭 서브넷 A (AZ 첫 번째)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1) # x.x.1.0/24
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = { Name = "KMS-PUBLIC-Azone-${var.env}" }
}

# 퍼블릭 서브넷 B (AZ 두 번째)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 2) # x.x.2.0/24
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = { Name = "KMS-PUBLIC-Bzone-${var.env}" }
}

# 프라이빗 서브넷 A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10) # x.x.10.0/24
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = { Name = "KMS-PRIVATE-WEB-Azone-${var.env}" }
}

# 프라이빗 서브넷 B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11) # x.x.11.0/24
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = { Name = "KMS-PRIVATE-WEB-Bzone-${var.env}" }
}

# 퍼블릭 라우팅 테이블 + IGW 연결
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "KMS-RT-PUBLIC-${var.env}" }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# NAT 게이트웨이용 EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "KMS-EIP-NAT-${var.env}" }
}

# NAT 게이트웨이 (프라이빗 서브넷 인터넷 출력용)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  tags = { Name = "KMS-NATGW-Azone-${var.env}" }

  depends_on = [aws_internet_gateway.main]
}

# 프라이빗 라우팅 테이블 + NAT 연결
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "KMS-RT-PRIVATE-${var.env}" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

# -------------------------------------------------------
# ALB용 Security Group
# -------------------------------------------------------
resource "aws_security_group" "alb" {
  name   = "KMS-SG-ALB-${var.env}"
  vpc_id = aws_vpc.main.id 

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

# 웹 서버용 Security Group
resource "aws_security_group" "web" {
  name   = "KMS-SG-WEB-${var.env}"
  vpc_id = aws_vpc.main.id 

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
  vpc_id   = aws_vpc.main.id 

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
  }

  tags = { Name = "KMS-TG-${var.env}" }
}

# ALB
resource "aws_lb" "main" {
  name               = "KMS-ALB-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id] 

  tags = { Name = "KMS-ALB-${var.env}" }
}

# ALB Listener
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
  name          = "KMS-LT-${var.env}"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>[${var.env}] KMS Web Server</h1>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "KMS-WEB-${var.env}" }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "KMS-ASG-${var.env}"
  vpc_zone_identifier = [aws_subnet.private_a.id, aws_subnet.private_b.id] # [수정] var.private_subnet_ids → 모듈 내부 서브넷
  target_group_arns   = [aws_lb_target_group.main.arn]
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "KMS-ASG-${var.env}"
    propagate_at_launch = true
  }
}
