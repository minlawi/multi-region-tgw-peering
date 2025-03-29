# Create VPC in the SG region
resource "aws_vpc" "vpc_sg" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.vpc_cidr[0]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name      = "vpc-sg"
    Terraform = "true"
  }
}

# Create two (2) public subnets in the SG region
resource "aws_subnet" "pub_subnets_sg" {
  count                   = var.create_vpc ? length(data.aws_availability_zones.az_sg.names) : 0
  vpc_id                  = aws_vpc.vpc_sg[0].id
  availability_zone       = data.aws_availability_zones.az_sg.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc_sg[0].cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-sg-${count.index}-${data.aws_availability_zones.az_sg.names[count.index]}"
    Terraform = "true"
  }
}

# Create IGW in the SG region
resource "aws_internet_gateway" "sg_igw" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_sg[0].id
  tags = {
    Name      = "sg-igw"
    Terraform = "true"
  }
}

# Create Public Route Table in the SG region
resource "aws_route_table" "pub_rtb_sg" {
  count  = var.create_vpc ? 1 : 0
  vpc_id = aws_vpc.vpc_sg[0].id
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