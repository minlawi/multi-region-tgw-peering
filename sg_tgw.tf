# Create a TGW in the SG region
resource "aws_ec2_transit_gateway" "sg_tgw" {
  count                           = var.create_vpc ? 1 : 0
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  description                     = "Transit Gateway for SG region"
  tags = {
    Name      = "sg-tgw"
    Terraform = "true"
  }
}

# Create a TGW Route Table in the SG region
resource "aws_ec2_transit_gateway_route_table" "tgw_rtb_sg" {
  count              = var.create_vpc ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.sg_tgw[0].id
  tags = {
    Name      = "sg-tgw-rtb"
    Terraform = "true"
  }

}

# Create a TGW Attachment for the VPC in the SG region
resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa_sg_vpc_a" {
  vpc_id             = aws_vpc.sg_vpc[0].id
  subnet_ids         = aws_subnet.pub_subnets_sg[*].id
  transit_gateway_id = aws_ec2_transit_gateway.sg_tgw[0].id
  tags = {
    Name      = "sg-tgw-attachment"
    Terraform = "true"
  }
}