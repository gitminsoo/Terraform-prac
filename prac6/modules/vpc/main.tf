# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-VPC" }
}

# 퍼블릭 서브넷 (AZ 개수만큼 생성)
resource "aws_subnet" "public" {
# CIDR을 list 형태로 받아서 length로 받는다
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-PUBLIC-${count.index == 0 ? "Azone" : "Czone"}"
  }
}

# 프라이빗 웹 서브넷
resource "aws_subnet" "private_web" {
  count             = length(var.private_web_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_web_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.name_prefix}-PRIVATE-WEB-${count.index == 0 ? "Azone" : "Czone"}"
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-IGW" }
}

# EIP — NAT GW용 (Azone만 생성, enable_nat_gateway가 true일 때)
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags   = { Name = "${var.name_prefix}-EIP-NATGW-Azone" }
}

# NAT 게이트웨이 (Azone 퍼블릭 서브넷에 배치)
resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.name_prefix}-NATGW-Azone" }

  depends_on = [aws_internet_gateway.igw]
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-RT-PUBLIC" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# 퍼블릭 서브넷 ↔ 퍼블릭 RT 연결
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 라우팅 테이블 (NAT GW 경유)
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.name_prefix}-RT-PRIVATE-WEB" }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[0].id
  }
}

# 프라이빗 서브넷 ↔ 프라이빗 RT 연결
resource "aws_route_table_association" "private_web" {
  count          = var.enable_nat_gateway ? length(aws_subnet.private_web) : 0
  subnet_id      = aws_subnet.private_web[count.index].id
  route_table_id = aws_route_table.private[0].id
}
