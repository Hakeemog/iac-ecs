# --- VPC ---

data "aws_availability_zones" "available" { state = "available" }

locals {
  azs_count = 2
  azs_names = data.aws_availability_zones.available.names
}

resource "aws_vpc" "max-ng" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "demo-vpc" }
}

resource "aws_subnet" "public" {
  count                   = local.azs_count
  vpc_id                  = aws_vpc.max-ng.id
  availability_zone       = local.azs_names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.max-ng.cidr_block, 8, 10 + count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = "demo-public-${local.azs_names[count.index]}" }
}

# --- Internet Gateway ---

resource "aws_internet_gateway" "max-ng" {
  vpc_id = aws_vpc.max-ng.id
  tags   = { Name = "demo-igw" }
}

resource "aws_eip" "max-ng" {
  count      = local.azs_count
  depends_on = [aws_internet_gateway.max-ng]
  tags       = { Name = "demo-eip-${local.azs_names[count.index]}" }
}

# --- Public Route Table ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.max-ng.id
  tags   = { Name = "demo-rt-public" }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.max-ng.id
  }
}

resource "aws_route_table_association" "public" {
  count          = local.azs_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}