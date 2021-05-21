resource "aws_route53_zone" "primary" {
  name = var.domain_name

  dynamic "vpc" {
    for_each = var.vpc_id[*]
    content {
      vpc_id = var.vpc_id
    }

  }
}
