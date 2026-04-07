# 가용 영역 목록 조회
data "aws_availability_zones" "available" {
  state = "available"
}

# KMS-VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = { Name = "KMS-VPC-${var.env}" }
}

# 퍼블릭 서브넷 (2개)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "KMS-PUBLIC-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 1))}zone-${var.env}" }
}

# 프라이빗 서브넷 (2개)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { Name = "KMS-PRIVATE-WEB-${upper(substr(data.aws_availability_zones.available.names[count.index], -2, 1))}zone-${var.env}" }
}

# KMS-IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "KMS-IGW-${var.env}" }
}

# EIP + NAT GW (퍼블릭 서브넷 첫 번째에 배치)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "KMS-EIP-NAT-${var.env}" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "KMS-NATGW-Azone-${var.env}" }
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "KMS-RT-PUBLIC-${var.env}" }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 라우팅 테이블
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "KMS-RT-PRIVATE-${var.env}" }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
