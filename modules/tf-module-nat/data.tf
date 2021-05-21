data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    "Project"     = var.project
    "Environment" = var.environment
    "Terraform"   = "True"
    "ManagedBy"   = var.managedby
  }
}
