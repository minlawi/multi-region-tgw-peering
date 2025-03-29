# Create a TGW in Japan region
resource "aws_ec2_transit_gateway" "tgw_jp" {
  provider                        = aws.japan
  count                           = var.create_vpc ? 1 : 0
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  description                     = "Transit Gateway for JP region"
  tags = {
    Name      = "tgw-jp"
    Terraform = "true"
  }
}

# Create TGW Route Table in Japan region
resource "aws_ec2_transit_gateway_route_table" "tgw_rtb_jp" {
  provider           = aws.japan
  count              = var.create_vpc ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.tgw_jp[0].id
  tags = {
    Name      = "tgw-rtb-jp"
    Terraform = "true"
  }
}

# Create TGW Attachment for the VPC in Japan region
resource "aws_ec2_transit_gateway_vpc_attachment" "tgwa_vpc_jp" {
  provider           = aws.japan
  count              = var.create_vpc ? 1 : 0
  vpc_id             = aws_vpc.vpc_jp[0].id
  subnet_ids         = tolist(aws_subnet.priv_subnets_tgw_jp[*].id)
  transit_gateway_id = aws_ec2_transit_gateway.tgw_jp[0].id
  tags = {
    Name      = "tgw-attachment-jp"
    Terraform = "true"
  }
}

# Associate the TGW Attachment with the TGW Route Table in Japan region
resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc_vpc_jp" {
  provider                       = aws.japan
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_jp[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_jp[0].id
}

# Propagate the TGW Attachment in the TGW Route Table in Japan region
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_rtb_propagation_vpc_jp" {
  provider                       = aws.japan
  count                          = var.create_vpc ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgwa_vpc_jp[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rtb_jp[0].id
}