variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "enable_dns" { default = "true" }
variable "enable_hostnames" { default = "true" }

#### might need to put this in root module
variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
variable "name" {}
variable "project" {}
variable "environment" {}
variable "managedby" {}
variable "primary_extra_tags" {
  type    = map(any)
  default = {}
}
variable "igw" {}
variable "natgw_ids" {
  #  type = list(string)
}




