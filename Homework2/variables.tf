variable "aws_access_key" {}
variable "aws_secret_key" {}


variable "aws_region" {
	default = "us-east-1"
}

variable "azs" {
	type = list(string)
	default = ["us-east-1a", "us-east-1b"]
}


variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    type = list(string)
    description = "CIDR for the Public Subnet"
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
    type = list(string)
    description = "CIDR for the Private Subnet"
    default = ["10.0.200.0/24", "10.0.201.0/24"]
}

variable "resource_count" {
   default = 2
}
variable "ingress_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [22]
}