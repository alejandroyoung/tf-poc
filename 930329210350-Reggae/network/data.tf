
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = {
    "Project"     = var.project,
    "Environment" = var.environment,
    "Terraform"   = "True",
    "ManagedBy"   = var.managedby
  }
}
