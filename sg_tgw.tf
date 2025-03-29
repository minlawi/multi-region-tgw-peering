# Create a TGW in the SG region
resource "aws_ec2_transit_gateway" "tgw_sg" {
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
  transit_gateway_id = aws_ec2_transit_gateway.tgw_sg[0].id
  tags = {
    Name      = "tgw-rtb-sg"
    Terraform = "true"
  }

}

# Create a TGW Attachment for the VPC in the SG region
resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa_vpc_sg" {
  count              = var.create_vpc ? 1 : 0
  vpc_id             = aws_vpc.vpc_sg[0].id
  subnet_ids         = tolist(aws_subnet.priv_subnets_tgw_sg[*].id)
  transit_gateway_id = aws_ec2_transit_gateway.tgw_sg[0].id
  tags = {
    Name      = "tgw-attachment-sg"
    Terraform = "true"
  }
}

# Associate the TGW Attachment with the TGW Route Table in the SG region
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc_sg" {
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_sg[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_sg[0].id
}

# Propagate the TGW Attachment in the TGW Route Table in the SG region
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rtb_propagation_sg" {
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_sg[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_sg[0].id
}

# Add "0.0.0.0/0" CIDR in the TGW Route Table in the SG region
resource "aws_ec2_transit_gateway_route" "tgw_route_vpc_sg" {
  count                          = var.create_vpc ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_sg[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_sg[0].id
}