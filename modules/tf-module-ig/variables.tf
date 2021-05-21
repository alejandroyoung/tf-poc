variable "vpc_id" {}
variable "project" {}
variable "environment" {}
variable "managedby" {}

variable "name" {}

variable "primary_extra_tags" {
  type    = map
  default = {}
}
