variable "region" {}
variable "name" {}
variable "project" {}
variable "environment" {}
variable "managedby" {}

variable "vpc_cidr" {}
variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
#variable "igw" {}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
