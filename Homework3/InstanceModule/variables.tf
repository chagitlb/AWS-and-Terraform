
variable "name" {
  description = "Name for enviroment"
  type        = string
}

variable "subnets" {
  description = "List of subnets for deployment"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI id"
  type        = string
}

variable "key_name" {
  description = "Name of key for remote access"
  type        = string
}

variable "security_groups" {
  description = "List of security group ids"
  type        = list(string)
}

variable "tags" {
  description = "Tags to add to all resources"
  type        = map(string)
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
variable "user_data" {
  description = "User data for EC2"
  type        = string
}