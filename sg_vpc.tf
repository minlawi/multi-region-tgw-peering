# Create VPC in the SG region
resource "aws_vpc" "sg_vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr[0]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name      = "vpc-sg"
    Terraform = "true"
  }
}

# Create Public Subnets in the SG region
resource "aws_subnet" "pub_subnets_sg" {
  count                   = var.create_vpc ? length(data.aws_availability_zones.az_sg.names) : 0
  vpc_id                  = aws_vpc.sg_vpc[0].id
  availability_zone       = data.aws_availability_zones.az_sg.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.sg_vpc[0].cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-sg-${count.index}-${data.aws_availability_zones.az_sg.names[count.index]}"
    Terraform = "true"
  }
}

# Create IGW in the SG region
resource "aws_internet_gateway" "sg_igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.sg_vpc[0].id
  tags = {
    Name      = "sg-igw"
    Terraform = "true"
  }
}

# Create Public Route Table in the SG region
resource "aws_route_table" "pub_rtb_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.sg_vpc[0].id
  # Create a route to the internet through the IGW
  route {
    gateway_id = aws_internet_gateway.sg_igw[0].id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name      = "sg-pub-rtb"
    Terraform = "true"
  }
}

# Associate the public route table with the public subnets in the SG region
resource "aws_route_table_association" "pub_rtb_assoc_sg" {
  count          = var.create_vpc ? length(aws_subnet.pub_subnets_sg) : 0
  subnet_id      = aws_subnet.pub_subnets_sg[count.index].id
  route_table_id = aws_route_table.pub_rtb_sg[0].id
}

# Create a EIP in the SG region
resource "aws_eip" "sg_eip" {
  count = var.create_vpc ? 1 : 0
  tags = {
    Name      = "sg-eip"
    Terraform = "true"
  }
}

# Create a NAT Gateway in the SG region
resource "aws_nat_gateway" "sg_nat_gw" {
  count         = var.create_vpc ? 1 : 0
  depends_on    = [aws_internet_gateway.sg_igw]
  allocation_id = aws_eip.sg_eip[0].id
  subnet_id     = aws_subnet.pub_subnets_sg[count.index].id
  tags = {
    Name      = "sg-nat-gw"
    Terraform = "true"
  }
}

# Create Private Subnets for workloads in the SG region
resource "aws_subnet" "priv_subnets_sg_workloads" {
  count             = var.create_vpc ? length(data.aws_availability_zones.az_sg.names) : 0
  vpc_id            = aws_vpc.sg_vpc[0].id
  availability_zone = data.aws_availability_zones.az_sg.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.sg_vpc[0].cidr_block, 8, count.index + length(data.aws_availability_zones.az_sg.names))
  tags = {
    Name      = "private-subnet-sg-workloads-${count.index}-${data.aws_availability_zones.az_sg.names[count.index]}"
    Terraform = "true"
  }
}

# Create Private Route Table for Workloads in the SG region
resource "aws_route_table" "priv_workloads_rtb" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.sg_vpc[0].id
  # Create a route to the NAT Gateway
  route {
    nat_gateway_id = aws_nat_gateway.sg_nat_gw[0].id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name      = "sg-priv-workloads-rtb"
    Terraform = "true"
  }
}

# Associate the private route table with the private subnets of workloads in the SG region
resource "aws_route_table_association" "priv_workloads_rtb_assoc" {
  count          = var.create_vpc ? length(aws_subnet.priv_subnets_sg_workloads) : 0
  subnet_id      = aws_subnet.priv_subnets_sg_workloads[count.index].id
  route_table_id = aws_route_table.priv_workloads_rtb[0].id
}

# Create Private Subnets for TGW in the SG region
resource "aws_subnet" "priv_subnets_sg_tgw" {
  count             = var.create_vpc ? length(data.aws_availability_zones.az_sg.names) : 0
  vpc_id            = aws_vpc.sg_vpc[0].id
  availability_zone = data.aws_availability_zones.az_sg.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.sg_vpc[0].cidr_block, 8, count.index + length(data.aws_availability_zones.az_sg.names) * 2)
  tags = {
    Name      = "private-subnet-sg-tgw-${count.index}-${data.aws_availability_zones.az_sg.names[count.index]}"
    Terraform = "true"
  }
}

# Create Private Route Table for TGW in the SG region
resource "aws_route_table" "priv_tgw_rtb" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.sg_vpc[0].id
  # Create a route to the NAT Gateway
  route {
    nat_gateway_id = aws_nat_gateway.sg_nat_gw[0].id
    cidr_block     = "0.0.0.0/0"
  }
  tags = {
    Name      = "sg-priv-tgw-rtb"
    Terraform = "true"
  }
}

# Associate the private route table with the private subnets of TGW in the SG region
resource "aws_route_table_association" "priv_tgw_rtb_assoc" {
  count          = var.create_vpc ? length(aws_subnet.priv_subnets_sg_tgw) : 0
  subnet_id      = aws_subnet.priv_subnets_sg_tgw[count.index].id
  route_table_id = aws_route_table.priv_tgw_rtb[0].id
}

# Add Tokyo's VPC CIDR in the Private Workloads and TGW Route Table

resource "aws_route" "sg_priv_workloads_rtb_tgw" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.priv_workloads_rtb[0].id
  destination_cidr_block = aws_vpc.vpc_jp[0].cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.sg_tgw[0].id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.tgwa_sg_vpc_a]
}

resource "aws_route" "sg_priv_tgw_rtb_tgw" {
  count                  = var.create_vpc ? 1 : 0
  route_table_id         = aws_route_table.priv_tgw_rtb[0].id
  destination_cidr_block = aws_vpc.vpc_jp[0].cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.sg_tgw[0].id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.tgwa_sg_vpc_a]
}