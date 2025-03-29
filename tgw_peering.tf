# Create Peering Connection between TGWs in Japan and Singapore regions
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  count = var.create_vpc ? 1 : 0
  # peer_account_id          = <AWS_ACCOUNT_ID> # Optional, specify if the peer TGW is in a different AWS account
  peer_region             = "ap-northeast-1" # Japan region
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_jp[0].id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw_sg[0].id
  tags = {
    Name      = "tgw-peering-requestor"
    Terraform = "true"
  }
}

# Retrieve the peering attachment ID for acceptance
data "aws_ec2_transit_gateway_peering_attachment" "tgw_peering_get_data" {
  count    = var.create_vpc ? 1 : 0
  provider = aws.japan
  filter {
    name   = "state"
    values = ["pendingAcceptance", "available"]
  }
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tgw_jp[0].id]
  }
  depends_on = [aws_ec2_transit_gateway_peering_attachment.tgw_peering]
}

# Accept the peering connection in TGW JP
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  count                         = var.create_vpc ? 1 : 0
  provider                      = aws.japan
  transit_gateway_attachment_id = var.create_vpc ? data.aws_ec2_transit_gateway_peering_attachment.tgw_peering_get_data[0].id : null
  tags = {
    Name      = "tgw-peering-accepter"
    Terraform = "true"
  }
}