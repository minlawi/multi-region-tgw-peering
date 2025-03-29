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