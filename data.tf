data "aws_availability_zones" "az_sg" {}

data "aws_availability_zones" "az_jp" {
  provider = aws.japan
}