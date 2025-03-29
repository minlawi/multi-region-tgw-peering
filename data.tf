data "aws_availability_zones" "az_sg" {}

data "aws_availability_zones" "az_tokyo" {
  provider = aws.tokyo
}