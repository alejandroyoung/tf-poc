
resource "aws_eip" "eip" {
  count = length(var.public_subnet_ids)
  vpc   = true

  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-eip"
    }
  )
}


resource "aws_nat_gateway" "natgw" {
  count         = length(aws_eip.eip.*.id)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(var.public_subnet_ids, count.index)

  tags = merge(
    local.common_tags, var.primary_extra_tags,
    {
      "Name" = "${var.environment}-${var.name}-nat"
    }
  )
}
