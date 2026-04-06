# Launch Template — Ubuntu + Nginx 자동 설치
resource "aws_launch_template" "web" {
  name_prefix   = "KMS-LT-"
  image_id      = data.aws_ami.ubuntu.id # Data Source에서 동적 조회
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
  }

  # 인스턴스 기동 시 Nginx 설치 및 간단한 HTML 페이지 생성
  # 169.254.169.254 는 실행중인 인스턴스에 접근 가능한 IP 
  # .../latest/meta-data/public-ipv4: 나의 퍼블릭 IP 조회
  # .../latest/meta-data/local-ipv4: 나의 프라이빗 IP 조회
  # .../latest/meta-data/iam/security-credentials/: 나에게 할당된 IAM 역할(Role)의 임시 보안 자격 증명 조회
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    echo "<h1>KMS Web Server</h1><p>Instance: $INSTANCE_ID</p><p>AZ: $AZ</p>" > /var/www/html/index.html
    systemctl start nginx
    systemctl enable nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "KMS-WEB-INSTANCE" }
  }

  tags = { Name = "KMS-LT" }
}

# Auto Scaling Group — 프라이빗 서브넷 분산 배치
resource "aws_autoscaling_group" "web" {
  name                = "KMS-ASG"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = aws_subnet.private[*].id # 프라이빗 서브넷에 배치

  # ALB Target Group에 자동 등록
  target_group_arns = [aws_lb_target_group.web.arn]

  health_check_type         = "ELB" # ALB Health Check 사용
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "KMS-ASG"
    propagate_at_launch = true
  }
}
