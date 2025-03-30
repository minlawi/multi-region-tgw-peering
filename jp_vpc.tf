# Create VPC in the JP region
resource "aws_vpc" "vpc_jp" {
  provider             = aws.japan
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr[1]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name      = "vpc-jp"
    Terraform = "true"
  }
}

# Create Public Subnets in the JP region
resource "aws_subnet" "pub_subnets_jp" {
  provider                = aws.japan
  count                   = var.create_vpc ? length(data.aws_availability_zones.az_jp.names) : 0
  vpc_id                  = aws_vpc.vpc_jp[0].id
  availability_zone       = data.aws_availability_zones.az_jp.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_jp[0].cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-jp-${count.index}-${data.aws_availability_zones.az_jp.names[count.index]}"
    Terraform = "true"
  }
}

# Create IGW in the JP region
resource "aws_internet_gateway" "igw_jp" {
  provider = aws.japan
  count    = var.create_vpc ? 1 : 0
  vpc_id   = aws_vpc.vpc_jp[0].id
  tags = {
    Name      = "igw-jp"
    Terraform = "true"
  }
}

# Create Public Route Table in the JP region
resource "aws_route_table" "pub_subnets_rtb_jp" {
  provider = aws.japan
  count    = var.create_vpc ? 1 : 0
  vpc_id   = aws_vpc.vpc_jp[0].id
  # Create a route to the internet through the IGW
  route {
    gateway_id = aws_internet_gateway.igw_jp[0].id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name      = "pub-rtb-jp"
    Terraform = "true"
  }
}

# Associate the public route table with the public subnets in the JP region
resource "aws_route_table_association" "pub_rtb_assoc_jp" {
  provider       = aws.japan
  count          = var.create_vpc ? length(aws_subnet.pub_subnets_jp) : 0
  subnet_id      = aws_subnet.pub_subnets_jp[count.index].id
  route_table_id = aws_route_table.pub_subnets_rtb_jp[0].id
}

# Create Private Subnets for workloads in the JP region
resource "aws_subnet" "priv_subnets_workloads_jp" {
  provider                = aws.japan
  count                   = var.create_vpc ? length(data.aws_availability_zones.az_jp.names) : 0
  vpc_id                  = aws_vpc.vpc_jp[0].id
  availability_zone       = data.aws_availability_zones.az_jp.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_jp[0].cidr_block, 8, count.index + length(data.aws_availability_zones.az_jp.names))
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-workloads-jp-${count.index}-${data.aws_availability_zones.az_jp.names[count.index]}"
    Terraform = "true"
  }
}

# Create Private Route Table for workloads in the JP region
resource "aws_route_table" "priv_subnets_workloads_rtb_jp" {
  provider = aws.japan
  count    = var.create_vpc ? 1 : 0
  vpc_id   = aws_vpc.vpc_jp[0].id
  tags = {
    Name      = "priv-rtb-workloads-jp"
    Terraform = "true"
  }
}

# Associate the private route table with the private subnets for workloads in the JP region
resource "aws_route_table_association" "priv_rtb_assoc_workloads_jp" {
  provider       = aws.japan
  count          = var.create_vpc ? length(aws_subnet.priv_subnets_workloads_jp) : 0
  subnet_id      = aws_subnet.priv_subnets_workloads_jp[count.index].id
  route_table_id = aws_route_table.priv_subnets_workloads_rtb_jp[0].id
}

# Create Private Subnets for TGW in the JP region
resource "aws_subnet" "priv_subnets_tgw_jp" {
  provider                = aws.japan
  count                   = var.create_vpc ? length(data.aws_availability_zones.az_jp.names) : 0
  vpc_id                  = aws_vpc.vpc_jp[0].id
  availability_zone       = data.aws_availability_zones.az_jp.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_jp[0].cidr_block, 8, count.index + length(data.aws_availability_zones.az_jp.names) * 2)
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-tgw-jp-${count.index}-${data.aws_availability_zones.az_jp.names[count.index]}"
    Terraform = "true"
  }
}

# Create Private Route Table for TGW in the JP region
resource "aws_route_table" "priv_subnets_tgw_rtb_jp" {
  provider = aws.japan
  count    = var.create_vpc ? 1 : 0
  vpc_id   = aws_vpc.vpc_jp[0].id
  tags = {
    Name      = "priv-rtb-tgw-jp"
    Terraform = "true"
  }
}

# Associate the private route table with the private subnets for TGW in the JP region
resource "aws_route_table_association" "priv_rtb_assoc_tgw_jp" {
  provider       = aws.japan
  count          = var.create_vpc ? length(aws_subnet.priv_subnets_tgw_jp) : 0
  subnet_id      = aws_subnet.priv_subnets_tgw_jp[count.index].id
  route_table_id = aws_route_table.priv_subnets_tgw_rtb_jp[0].id
}

# Add "0.0.0.0/0" route to the private route tables of workloads and TGW in the JP region

resource "aws_route" "default_route_rtb_workloads_jp" {
  provider               = aws.japan
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.priv_subnets_workloads_rtb_jp[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_jp[0].id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_jp]
}

resource "aws_route" "default_route_rtb_tgw_jp" {
  provider               = aws.japan
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.priv_subnets_tgw_rtb_jp[0].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_jp[0].id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_jp]
}