variable "create_vpc" {
  description = "Create a VPC"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = list(string)
  default     = []
}

variable "profile" {
  description = "AWS profile to use"
  type        = string
  default     = ""
}