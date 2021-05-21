resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-public-subnet"
    }
  )
}
