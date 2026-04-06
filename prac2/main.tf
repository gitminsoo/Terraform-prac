# =========================================
# Provider 설정
# =========================================

terraform {
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
    required_version = ">= 1.0"
}

provider "aws"{
    region = "ap-south-1"
}

# =========================================
# VPC
# =========================================

resource "aws_vpc" "main-vpc"{
    cidr_block = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "KMS-VPC"
    }
}

# =========================================
# 퍼블릭 서브넷
# =========================================


resource "aws_subnet" "public_a" {
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "10.0.10.0/24"
    availability_zone = "ap-south-1a"
    # ec2 생성 시 public_ip 부여
    map_public_ip_on_launch = true

    tags = {
        Name = "KMS-PUBLIC-Azone"
    }
}

resource "aws_subnet" "public_c"{
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "10.0.110.0/24"
    availability_zone = "ap-south-1c"
    map_public_ip_on_launch = true

    tags = {
        Name = "KMS-PUBLIC-Czone"
    }
}


# =========================================
# 프라이빗 서브넷 (WEB 계층)
# =========================================


resource "aws_subnet" "private_web_a"{
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "KMS-PRIVATE-WEB-Azone"
    }
}

resource "aws_subnet" "private_web_c"{
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = "10.0.120.0/24"
    availability_zone="ap-south-1c"

    tags={
        Name = "KMS-PRIVATE-WEB-Czone"
    }
}

# =========================================
# Internet Gateway
# =========================================

resource "aws_internet_gateway" "main"{
    vpc_id = aws_vpc.main-vpc.id

    tags = {
        Name = "KMS-IGW"
    }
}


# =========================================
# EIP (NAT GW용)
# =========================================

resource "aws_eip" "nat_a" {
    domain = "vpc"

    tags = {
        Name = "KMS-EIP-NATGW-Azone"
    }
}


resource "aws_eip" "nat_c" {
    domain = "vpc"

    tags = {
        Name = "KMS-EIP-NATGW-Czone"
    }
}

# =========================================
# NAT Gateway (각 AZ별 퍼블릭 서브넷에 배치)
# =========================================

resource "aws_nat_gateway" "nat_a"{
    allocation_id = aws_eip.nat_a.id
    subnet_id = aws_subnet.public_a.id

    tags = {
        Name = "KMS-NATGW-Azone"
    }

    # 인터넷 게이트웨이가 생긴 후 실행한다
    depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat_c" {
    allocation_id = aws_eip.nat_c.id
    subnet_id = aws_subnet.public_c.id

    tags = {
        Name = "KMS-NATGW-Czone"
    }
}

# =========================================
# 라우팅 테이블 — PUBLIC (IGW 경유)
# =========================================

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    
    tags = {
        Name = "KMS-RT-PUBLIC"
    }
}

resource "aws_route_table_association" "public_a" {
    subnet_id = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}



# =========================================
# 라우팅 테이블 — PRIVATE-A (NATGW-Azone 경유)
# =========================================
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = {
    Name = "KMS-RT-PRIVATE-A"
  }
}

resource "aws_route_table_association" "private_web_a" {
  subnet_id      = aws_subnet.private_web_a.id
  route_table_id = aws_route_table.private_a.id
}

# =========================================
# 라우팅 테이블 — PRIVATE-C (NATGW-Czone 경유)
# =========================================
resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_c.id
  }

  tags = {
    Name = "KMS-RT-PRIVATE-C"
  }
}

resource "aws_route_table_association" "private_web_c" {
  subnet_id      = aws_subnet.private_web_c.id
  route_table_id = aws_route_table.private_c.id
}

# =========================================
# Outputs
# =========================================
output "vpc_id" {
  value       = aws_vpc.main-vpc.id
  description = "KMS-VPC ID"
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_c.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_web_a.id, aws_subnet.private_web_c.id]
}






