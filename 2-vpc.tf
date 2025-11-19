resource "aws_vpc" "class_7_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true 
  enable_dns_support = true 
  tags = {
    Name    = "class_7_vpc"
    Service = "terraform"
  }
}

resource "aws_subnet" "public_class_7_subnet" {
  vpc_id                  = aws_vpc.class_7_vpc.id
  for_each                = var.public_subnet_config
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name    = each.key
    Service = "terraform"
    VPC     = "class_7_vpc"
  }
}

resource "aws_subnet" "private_class_7_subnet" {
  vpc_id                  = aws_vpc.class_7_vpc.id
  for_each                = var.private_subnet_config
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = {
    Name    = each.key
    Service = "terraform"
    VPC     = "class_7_vpc"
  }
}

resource "aws_internet_gateway" "class_7_igw" {
  vpc_id = aws_vpc.class_7_vpc.id
  tags = {
    Name    = "class_7_igw"
    Service = "terraform"
    VPC     = "class_7_vpc"
  }
}

resource "aws_eip" "class7_nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.class_7_igw]
  tags = {
    Name = "class7_nat_eip"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "class7_nat_gateway" {
  depends_on    = [aws_subnet.public_class_7_subnet]
  allocation_id = aws_eip.class7_nat_gateway_eip.id
  subnet_id     = aws_subnet.public_class_7_subnet["public_class7_subnet_1"].id
  tags = {
    Name = "class7_nat_gateway"
  }
}


resource "aws_route_table" "class_7_public_rtb" {
  vpc_id = aws_vpc.class_7_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.class_7_igw.id
  }
  tags = {
    Name    = "class_7_subnet"
    Service = "terraform"
    VPC     = "class_7_vpc"
  }
}


resource "aws_route_table" "class_7_private_rtb" {
  vpc_id = aws_vpc.class_7_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.class7_nat_gateway.id
  }
  tags = {
    Name    = "class_7_private_rtb"
    Service = "terraform"
    VPC     = "class_7_vpc"
  }
}


resource "aws_route_table_association" "class_7_public_rtb_association" {
  for_each       = aws_subnet.public_class_7_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.class_7_public_rtb.id
}


resource "aws_route_table_association" "class_7_private_rtb_association" {
  for_each       = aws_subnet.private_class_7_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.class_7_private_rtb.id
}